{pkgs, ...}: {
  home.packages = with pkgs.jetbrains; [
    idea-ultimate
    pycharm-professional
    webstorm
    datagrip
  ];
}
