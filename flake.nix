{
  description = "My nix config";

  inputs = {
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Homebrew casks as Nix packages (macOS only)
    brew-nix.url = "github:BatteredBunny/brew-nix";
    brew-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-wsl,
    nix-darwin,
    home-manager,
    brew-nix,
    ...
  } @ inputs: let
    inherit (self) outputs;
    nixosVersion = "25.11";
    systems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    nixosConfigurations = {
      wsl-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs nixosVersion;};
        modules = [
          ./nixos/wsl-configuration.nix
          nixos-wsl.nixosModules.default
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            system.stateVersion = nixosVersion;
            wsl.enable = true;
          }
        ];
      };
    };
    darwinConfigurations = {
      privateMac = nix-darwin.lib.darwinSystem {
        modules = [./nix-darwin/privateMac-configuration.nix];
      };
      businessMac = nix-darwin.lib.darwinSystem {
        modules = [./nix-darwin/businessMac-configuration.nix];
      };
    };

    homeConfigurations = let
      # macOS用pkgs（brew-nix overlay適用）
      pkgs-darwin = import nixpkgs {
        system = "aarch64-darwin";
        overlays = [brew-nix.overlays.default];
        config.allowUnfree = true;
      };
      # nixpkgs-unstable（google-chrome等、brew-nixで問題があるパッケージ用）
      pkgs-unstable-darwin = import nixpkgs-unstable {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
      # WSL用pkgs-unstable
      pkgs-unstable-linux = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in {
      "nixos@wsl-nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs nixosVersion;
          systemType = "wsl";
          pkgs-unstable = pkgs-unstable-linux;
        };
        modules = [
          ./home-manager/wsl-home.nix
        ];
      };
      "nakazye@privateMac" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs-darwin;
        extraSpecialArgs = {
          inherit inputs outputs nixosVersion;
          systemType = "privateMac";
          pkgs-unstable = pkgs-unstable-darwin;
        };
        modules = [
          ./home-manager/privateMac-home.nix
        ];
      };
      "businessMac" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs-darwin;
        extraSpecialArgs = {
          inherit inputs outputs nixosVersion;
          systemType = "businessMac";
          pkgs-unstable = pkgs-unstable-darwin;
        };
        modules = [
          ./home-manager/businessMac-home.nix
        ];
      };
    };
  };
}
