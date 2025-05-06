{pkgs, ...}: {

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

  system = {
    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToControl = true;
    defaults.trackpad.Clicking = true; # tap to click
    defaults.trackpad.TrackpadRightClick = true;
    defaults.CustomUserPreferences = {
      "com.apple.inputmethod.Kotoeri" = {
        "JIMPrefLiveConversionKey" = false; # ライブ変換をオフ
      };
    };
    defaults.dock.minimize-to-application = true;
    defaults.dock.persistent-apps = [
      "/System/Applications/Launchpad.app"
      "/Applications/1Password.app"
      "/Applications/Orion.app"
      "/Applications/Slack.app"
      "/Applications/Alacritty.app"
      "/Users/nakazye/Applications/Home Manager Apps/Emacs.app"
    ];
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
    };
    casks = [
      "1password"
      "slack"
      "orion"
      "raycast"
      "alacritty"
    ];
  };

  fonts = {
    packages = with pkgs; [
      hackgen-nf-font
      nerdfonts
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
