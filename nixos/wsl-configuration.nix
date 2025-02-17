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

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ anthy ];
  };
  
  system.stateVersion = "24.11";
}
