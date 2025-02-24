{ config, lib, pkgs, ... }: {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

  fonts.packages = with pkgs; [
    hackgen-nf-font
    nerdfonts
    noto-fonts-color-emoji
  ];

  environment.systemPackages = with pkgs; [
#    anthy
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  
  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
  };
  
  system.stateVersion = "24.11";
}
