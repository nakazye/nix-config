# macOS共通設定
{pkgs, ...}: {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

  system = {
    # キーボードマッピング変更機能を有効化（Caps Lock→Control変更に必要）
    keyboard.enableKeyMapping = true;
    # Caps LockキーをControlキーにリマップ
    keyboard.remapCapsLockToControl = true;
    # F1-F12キーをfnキーなしで直接使用可能に設定
    defaults.NSGlobalDomain."com.apple.keyboard.fnState" = true;
    # キーを長押しした時のリピート間隔（1が最速）
    defaults.NSGlobalDomain.KeyRepeat = 2;
    # キーを押してからリピートが始まるまでの遅延時間（数値が小さいほど早い）
    defaults.NSGlobalDomain.InitialKeyRepeat = 11;
    # トラックパッドのタップでクリック機能を有効化
    defaults.trackpad.Clicking = true;
    # トラックパッドの右クリック機能を有効化
    defaults.trackpad.TrackpadRightClick = true;
    defaults.CustomUserPreferences = {
      "com.apple.inputmethod.Kotoeri" = {
        "JIMPrefLiveConversionKey" = false; # ライブ変換をオフ
      };
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # Spotlight検索のCmd+Spaceを無効化
          "64" = {
            enabled = false;
          };
          # Finderの検索ウィンドウのCmd+Option+Spaceを無効化
          "65" = {
            enabled = false;
          };
        };
      };
    };
    # ウィンドウ最小化時にアプリケーションアイコンに収納
    defaults.dock.minimize-to-application = true;

    stateVersion = 5;
  };

  # sudoコマンド実行時にTouch IDによる指紋認証を有効化
  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    # Homebrewパッケージマネージャーを有効化
    enable = true;
    onActivation = {
      # システム再構築時にHomebrew自体を自動更新
      autoUpdate = true;
      # 設定にないアプリケーションを自動削除
      cleanup = "uninstall";
    };
  };

  fonts = {
    packages = with pkgs; [
      hackgen-nf-font
      nerd-fonts.symbols-only
    ];
  };

  environment.variables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  # 1PasswordのSSHエージェントを使用してSSH鍵を管理
  programs.ssh.extraConfig = ''
    Host *
      IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  '';

  programs.zsh.enable = true;

  time.timeZone = "Asia/Tokyo";

  nixpkgs.hostPlatform = "aarch64-darwin";
}
