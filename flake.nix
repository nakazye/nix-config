{
  description = "My nix config";

  inputs = {
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
      self,
      nixpkgs,
      nixos-wsl,
      nix-darwin,
      home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [
      "aarch64-linux"
      "i686-linux"
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

    # Available through 'sudo nixos-rebuild switch --flake .#wsl-nixos'
    nixosConfigurations = {
      wsl-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nixos/wsl-configuration.nix
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "24.11";
            wsl.enable = true;
          }
        ];
      };
      hp-spectre = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nixos/hp-spectre-configuration.nix
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "24.11";
          }
        ];
      };

    };

    darwinConfigurations = {
      MBP14-M3Pro-2023 = nix-darwin.lib.darwinSystem {
        modules = [ ./nix-darwin/MBP14-M3Pro-2023-configuration.nix ];
      };
    };

    # Available through 'home-manager switch --flake .#nixos@wsl-nixos'
    homeConfigurations = {
      "nixos@wsl-nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home-manager/wsl-home.nix
        ];
      };
      "nakazye@hp-spectre" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home-manager/nixos-home.nix
        ];
      };
      "nakazye@MBP14-M3Pro-2023" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home-manager/darwin-home.nix
        ];
      };
    };
  };
}
