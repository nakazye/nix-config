{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

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
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    # Tools
    unar
    chezmoi
    fd
    ripgrep
    tree-sitter
    ghq
    peco
    mozc
    tree
    # Lang
    gnumake
    cmake
    gcc
    libtool
    jdk
    python3
    # App
    (emacs.override {
      withTreeSitter = true;
      withNativeCompilation = true;
      # Windowsとのクリップボード連携がおかしくなるのでいったんコメントアウト
#      withXwidgets = true;
#      withPgtk = true;
    })
    vim
    neovim
  ];

  programs.git = {
    extraConfig = {
      core = {
        autocrlf = false;
        filemode = false;
        editor = "nvim";
        sshCommand = "/mnt/c/Windows/System32/OpenSSH/ssh.exe";
      };
#      init = {
#        defaultBranch = "main";
#      };
      ghq = {
        root = "~/src";
      };
    };
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
