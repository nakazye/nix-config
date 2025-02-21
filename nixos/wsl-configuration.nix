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
  
  system.stateVersion = "24.11";
}
