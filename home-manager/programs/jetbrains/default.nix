{pkgs, ...}: {
  home.packages = with pkgs.jetbrains; [
    idea
    pycharm
    webstorm
    datagrip
  ];
}
