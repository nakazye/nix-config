{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  nixosVersion,
  ...
}: {
  imports = [
    ./programs/default.nix
  ];

  # WSLではGUIアプリ不要
  disabledModules = [
    ./programs/alt-tab
    ./programs/discord
    ./programs/doll
    ./programs/google-chrome
    ./programs/jetbrains
    ./programs/jordanbaird-ice
    ./programs/orion
    ./programs/raycast
    ./programs/slack
    ./programs/voiceink
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
  };

  home.packages = with pkgs; [
    mozc
    noto-fonts-color-emoji
  ];

  programs.home-manager.enable = true;

  # Linuxのみで有効: Home Manager設定変更時にsystemdユーザーサービスを適切に再読み込み
  systemd.user.startServices = "sd-switch";

  home.stateVersion = nixosVersion;
}
