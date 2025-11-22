{pkgs, ...}: {

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

  system = {
    primaryUser = "nakazye";
    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToControl = true;
    defaults.NSGlobalDomain."com.apple.keyboard.fnState" = true; # fnキーを就職キーなしで
    defaults.trackpad.Clicking = true; # tap to click
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
    defaults.dock.minimize-to-application = true;
    defaults.dock.persistent-apps = [
      "/System/Applications/Apps.app"
    ];
  };
  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
    };
    casks = [
      "1password"
      "atok"
      "wezterm"
      "slack"
      "discord"
      "orion"
      "raycast"
      "bettertouchtool"
      "doll"
      "jordanbaird-ice"
# エラー出るので、一旦普通に入れる方向で
#      "parallels"
      "alt-tab"
      # JetBrains
      "intellij-idea"
      "pycharm"
      "webstorm"
      "datagrip"
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

  programs.ssh.extraConfig = ''
    Host *
      IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';

  programs.zsh.enable = true;

  time.timeZone = "Asia/Tokyo";

  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
