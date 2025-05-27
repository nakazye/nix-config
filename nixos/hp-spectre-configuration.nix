{ config, lib, pkgs, ... }: {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

  imports =
    [ # Include the results of the hardware scan.
      /home/nakazye/.local/share/nix-config/nixos/hp-spectre-hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.xserver.xkbOptions = "caps:ctrl_modifier";
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.nakazye = {
    isNormalUser = true;
    description = "nakazye";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "nakazye";
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  nixpkgs.config.allowUnfree = true;

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
  
  system.stateVersion = "25.05";
}
