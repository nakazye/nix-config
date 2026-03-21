{
  pkgs,
  lib,
  ...
}: {
  home.packages = [
    (lib.meta.lowPrio pkgs.brewCasks.claude)
  ];
}
