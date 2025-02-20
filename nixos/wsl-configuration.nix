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
  
  system.stateVersion = "24.11";
}
