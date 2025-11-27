{
  description = "My nix config";

  inputs = {
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-wsl,
    nix-darwin,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    nixosVersion = "25.05";
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
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs nixosVersion;};
        modules = [
          ./nixos/wsl-configuration.nix
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = nixosVersion;
            wsl.enable = true;
          }
        ];
      };
    };
    darwinConfigurations = let
      pkgs-unstable = import nixpkgs-unstable {
        system = "aarch64-darwin";
        config.allowUnfreePredicate = pkg:
          builtins.elem (pkg.pname or (builtins.parseDrvName pkg.name).name) [
            "1password"
            "1password-cli"
          ];
      };
    in {
      privateMac = nix-darwin.lib.darwinSystem {
        specialArgs = {inherit pkgs-unstable;};
        modules = [./nix-darwin/privateMac-configuration.nix];
      };
      businessMac = nix-darwin.lib.darwinSystem {
        specialArgs = {inherit pkgs-unstable;};
        modules = [./nix-darwin/businessMac-configuration.nix];
      };
    };

    homeConfigurations = {
      "nixos@wsl-nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs nixosVersion;
          isWSL = true;
        };
        modules = [
          ./home-manager/wsl-home.nix
        ];
      };
      "nakazye@privateMac" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {
          inherit inputs outputs nixosVersion;
          isWSL = false;
        };
        modules = [
          ./home-manager/privateMac-home.nix
        ];
      };
      "businessMac" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {
          inherit inputs outputs nixosVersion;
          isWSL = false;
        };
        modules = [
          ./home-manager/businessMac-home.nix
        ];
      };
    };
  };
}
