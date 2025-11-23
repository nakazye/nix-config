{
  description = "My nix config";

  inputs = {
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
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
    darwinConfigurations = {
      privateMac = nix-darwin.lib.darwinSystem {
        modules = [ ./nix-darwin/privateMac-configuration.nix ];
      };
    };

    homeConfigurations = {
      "nixos@wsl-nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs nixosVersion; isWSL = true;};
        modules = [
          ./home-manager/wsl-home.nix
        ];
      };
      "nakazye@privateMac" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {inherit inputs outputs nixosVersion; isWSL = false;};
        modules = [
          ./home-manager/darwin-home.nix
        ];
      };
    };
  };
}
