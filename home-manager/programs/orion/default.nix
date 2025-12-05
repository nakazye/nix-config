{
  pkgs,
  systemType,
  ...
}: {
  home.packages = [
    (pkgs.brewCasks.orion.override {
      variation =
        if systemType == "businessMac"
        then "sequoia"
        else null;
    })
  ];
}
