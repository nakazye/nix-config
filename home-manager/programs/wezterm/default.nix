{
  config,
  lib,
  pkgs,
  ...
}: let
  signingIdentity = "Home Manager Code Signing";
  appDir = "$HOME/${config.targets.darwin.copyApps.directory}/WezTerm.app";
  setupScript = pkgs.writeShellScriptBin "wezterm-codesign-setup" ''
    set -euo pipefail
    identities="$(/usr/bin/security find-identity -p codesigning)"
    if [[ "$identities" == *'"${signingIdentity}"'* ]]; then
      echo "identity \"${signingIdentity}\" already exists" >&2
      exit 0
    fi
    tmp="$(/usr/bin/mktemp -d)"
    trap '/bin/rm -rf "$tmp"' EXIT
    /usr/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
      -subj "/CN=${signingIdentity}" \
      -addext "keyUsage=critical,digitalSignature" \
      -addext "extendedKeyUsage=critical,codeSigning" \
      -keyout "$tmp/key.pem" -out "$tmp/cert.pem" 2>/dev/null
    /usr/bin/openssl pkcs12 -export -inkey "$tmp/key.pem" -in "$tmp/cert.pem" \
      -out "$tmp/cert.p12" -passout pass:tmp
    /usr/bin/security import "$tmp/cert.p12" -k "$HOME/Library/Keychains/login.keychain-db" \
      -P tmp -T /usr/bin/codesign
    echo "created identity \"${signingIdentity}\"." >&2
    echo "next: run home-manager switch, then re-grant Full Disk Access and App Management to WezTerm once." >&2
  '';
in {
  home.packages = [setupScript];

  # nixpkgsのWezTermはアドホック署名で、指定要件がcdhashになる。
  # 更新でバイナリが変わるとTCC（フルディスクアクセス・アプリ管理）の許可が外れるため、
  # ログインキーチェーンの自己署名証明書で署名し直して指定要件を固定する。
  # 証明書はマシンごとに作成し、無いマシンではアドホック署名のまま何もしない
  home.activation.weztermCodesign = lib.hm.dag.entryAfter ["copyApps"] ''
    weztermIdentity="$(/usr/bin/security find-identity -p codesigning 2>/dev/null \
      | /usr/bin/awk 'index($0, "\"${signingIdentity}\"") {print $2; exit}')"
    # バンドルのルートに実行ファイルが並ぶ構成のため、バンドル内のまま署名すると
    # バンドル全体の署名扱いになり失敗する。外にコピーして署名してから戻す
    weztermResign() {
      local tmp rc
      tmp="$(mktemp -d)" || return 1
      run cp "${appDir}/wezterm-gui" "$tmp/wezterm-gui" \
        && run /usr/bin/codesign --force --sign "$weztermIdentity" "$tmp/wezterm-gui" \
        && run mv -f "$tmp/wezterm-gui" "${appDir}/wezterm-gui"
      rc=$?
      rm -rf "$tmp"
      return $rc
    }
    if [[ ! -d "${appDir}" ]]; then
      :
    elif [[ -z "$weztermIdentity" ]]; then
      echo "skipping WezTerm re-signing: identity \"${signingIdentity}\" not found" >&2
      echo "  to keep TCC permissions across updates, run: wezterm-codesign-setup" >&2
    elif ! weztermResign; then
      echo "warning: failed to re-sign WezTerm; TCC permissions may be reset" >&2
    fi
  '';

  programs.wezterm = {
    enable = true;
    # シェル統合を無効化（他のターミナルでもロードされて遅延の原因になる）
    enableZshIntegration = false;
    enableBashIntegration = false;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()
      config.automatically_reload_config = true

      config.font = wezterm.font('PlemolJP Console NF')
      config.font_size = 18.0
      config.use_ime = true
      config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'
      config.enable_tab_bar = false
      config.disable_default_key_bindings = true

      -- Sanrio Night (dark)
      config.colors = {
        foreground    = '#f9e9f2',
        background    = '#1b1118',
        cursor_bg     = '#e383a8',
        cursor_fg     = '#1b1118',
        cursor_border = '#e383a8',
        selection_fg  = '#f9e9f2',
        selection_bg  = '#3a2432',
        scrollbar_thumb = '#3a2432',
        split         = '#3a2432',
        ansi = {
          '#271a22',  -- black    bg-alt
          '#f08080',  -- red      Hello Kitty
          '#91dea9',  -- green    けろっぴ
          '#efc128',  -- yellow   キキ&ララ (星)
          '#72b8f0',  -- blue     シナモロール
          '#e383a8',  -- magenta  ララ (LTS ピンク)
          '#8bd0dd',  -- cyan     キキ (LTS 水色)
          '#c8a4bc',  -- white    fg-dim
        },
        brights = {
          '#8a7082',  -- bright black    gray
          '#f06aaa',  -- bright red      マイメロ
          '#bcd60a',  -- bright green    けろっぴ (明)
          '#efa42b',  -- bright yellow   ポムポムプリン
          '#cda1dc',  -- bright blue     クロミ
          '#f06aaa',  -- bright magenta  マイメロ
          '#8bd0dd',  -- bright cyan     キキ
          '#f9e9f2',  -- bright white    fg
        },
      }

      config.keys = {
        {
          key = 'v',
          mods = 'CMD',
          action = wezterm.action.PasteFrom 'Clipboard',
        },
        {
          key = 'c',
          mods = 'CMD',
          action = wezterm.action.CopyTo 'Clipboard',
        },
      }

      return config
    '';
  };
}
