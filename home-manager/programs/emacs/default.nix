{pkgs, ...}: {
  home.packages = [
    pkgs.emacs
    pkgs.imagemagick
  ];
}
