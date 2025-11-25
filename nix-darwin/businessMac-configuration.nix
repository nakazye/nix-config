# UID/GIDが使われている場合の対応
#
# 1,GID/UIDは以下で変えれる
# export NIX_BUILD_GROUP_ID=4000
# export NIX_FIRST_BUILD_UID=4001
# sudo sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
#
# 2,一方、UIDは変えるにしても再設定が必要そう
# curl --proto '=https' --tlsv1.2 -sSf -L https://github.com/NixOS/nix/raw/master/scripts/sequoia-nixbld-user-migration.sh | bash -
#
# 3,configに、使ってるUIDとGIDの指定が必要
#   ids.uids.nixbld = 351;
#   ids.gids.nixbld = 4000;
#
{pkgs, ...}: 
let
  # sudo実行時でも元のユーザー名を取得
  username = let
    sudoUser = builtins.getEnv "SUDO_USER";
    currentUser = builtins.getEnv "USER";
  in
    if sudoUser != "" then sudoUser else currentUser;
in
{

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

  system = {
    primaryUser = username;
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
    # Dockに固定表示するアプリケーション
    defaults.dock.persistent-apps = [
#      "/System/Applications/Apps.app"
    ];
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
    casks = [
      "1password"
      "atok"
      "slack"
      "orion"
      "raycast"
      "bettertouchtool"
      "doll"
      "jordanbaird-ice"
      "alt-tab"
      # JetBrains
      "intellij-idea"
      "pycharm"
      "webstorm"
      "datagrip"
      # プロジェクト特有
      "aws-vpn-client"
      "google-chrome"
    ];
  };

  fonts = {
    packages = with pkgs; [
      hackgen-nf-font
      nerd-fonts.symbols-only
    ];
  };

  environment.variables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
  };

  # 1PasswordのSSHエージェントを使用してSSH鍵を管理
  programs.ssh.extraConfig = ''
    Host *
      IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';

  programs.zsh.enable = true;

  time.timeZone = "Asia/Tokyo";

  system.stateVersion = 5;
  ids.uids.nixbld = 351;
  ids.gids.nixbld = 4000;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
