{ config, lib, pkgs, ... }: {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

  fonts.packages = with pkgs; [
    hackgen-nf-font
    nerdfonts    
  ];

  environment.systemPackages = with pkgs; [
#    anthy
  ];
  
  system.stateVersion = "24.11";
}
