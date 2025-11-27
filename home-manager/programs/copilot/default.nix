{pkgs, ...}: let
  nodePkgs = pkgs.callPackage ../../../pkgs/node-composition.nix {inherit pkgs;};
in {
  home.packages = [nodePkgs."@github/copilot"];
}
