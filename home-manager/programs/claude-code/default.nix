{
  pkgs-unstable,
  config,
  ...
}: {
  home.packages = [pkgs-unstable.claude-code];

  home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;

  # direnv連携: BASH_ENVではなくSessionStart/CwdChangedフック経由でCLAUDE_ENV_FILEに反映。
  # BASH_ENVを使わないため、nixが生成する子bashがBASH_ENVを再読込して無限再帰する
  # fork bomb（過去に発生）が構造的に起きない。direnvはセッション開始時とcwd変更時のみ実行。
  # 公式推奨方式（anthropics/claude-code#42229）。
  home.file.".config/claude/load-direnv.sh".text = ''
    # CLAUDE_ENV_FILE未提供時やdirenv未導入時は何もしない
    [ -n "''${CLAUDE_ENV_FILE:-}" ] || exit 0
    command -v direnv >/dev/null 2>&1 || exit 0

    snapshot="$CLAUDE_ENV_FILE.direnv"

    # CLAUDE_ENV_FILEは追記専用。snapshotをsourceする1行だけを一度だけ追記し、
    # 実体のenvはsnapshot側を毎回上書きすることで最新のcwdを反映する。
    if ! grep -qF "$snapshot" "$CLAUDE_ENV_FILE" 2>/dev/null; then
      printf '. %q\n' "$snapshot" >> "$CLAUDE_ENV_FILE"
    fi

    # 末尾のecho trueは、direnv exportの行末「;」が&&連結で「; &&」構文エラーに
    # なるのを防ぐ定石（#42229）。
    {
      direnv export bash 2>/dev/null
      echo true
    } > "$snapshot"

    exit 0
  '';

  home.file.".claude/settings.json".text = builtins.toJSON {
    enabledPlugins = {
      "clangd-lsp@claude-plugins-official" = true;
    };
    alwaysThinkingEnabled = true;
    prefersReducedMotion = true;
    permissions = {
      allow = [
        "Bash(iconv:*)"
      ];
    };
    hooks = let
      loadDirenv = "bash ${config.home.homeDirectory}/.config/claude/load-direnv.sh || true";
    in {
      # direnv: セッション開始時とcwd変更時にCLAUDE_ENV_FILEへenvを反映
      SessionStart = [
        {
          hooks = [
            {
              type = "command";
              command = loadDirenv;
            }
          ];
        }
      ];
      CwdChanged = [
        {
          hooks = [
            {
              type = "command";
              command = loadDirenv;
            }
          ];
        }
      ];
      # oletoolsを含むBashコマンドを決定論的にブロック（会社のウイルススキャンが誤検知するため）。
      # stdinのJSON（tool_input.command含む）にoletoolsがあればexit 2で実行拒否。grepのみでjq非依存。
      PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "if grep -qi oletools; then echo 'oletools は実行/インストール禁止です（会社のウイルススキャンが誤検知するため）。CLAUDE.md参照。' >&2; exit 2; fi";
            }
          ];
        }
      ];
    };
  };
}
