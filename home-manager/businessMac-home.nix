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

  # セキュリティソフトがブロックするので、claude-codeを無効化
  disabledModules = [
    ./programs/claude-code
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
    sessionPath = [
      "$HOME/.local/bin"
    ];
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
  ];

  programs.home-manager.enable = true;
  home.stateVersion = nixosVersion;
}
