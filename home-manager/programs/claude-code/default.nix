{
  pkgs-unstable,
  config,
  ...
}: {
  home.packages = [pkgs-unstable.claude-code];

  home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;

  # BASH_ENV経由でdirenvを非インタラクティブbashに自動適用（IDE拡張でも有効）
  home.file.".config/claude/direnv.sh".text = ''
    eval "$(direnv export bash 2>/dev/null)" || true
  '';

  home.file.".claude/settings.json".text = builtins.toJSON {
    enabledPlugins = {
      "clangd-lsp@claude-plugins-official" = true;
    };
    alwaysThinkingEnabled = true;
    prefersReducedMotion = true;
    env = {
      BASH_ENV = "${config.home.homeDirectory}/.config/claude/direnv.sh";
    };
    permissions = {
      allow = [
        "Bash(iconv:*)"
      ];
    };
    # oletoolsを含むBashコマンドを決定論的にブロック（会社のウイルススキャンが誤検知するため）。
    # stdinのJSON（tool_input.command含む）にoletoolsがあればexit 2で実行拒否。grepのみでjq非依存。
    hooks = {
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
