{pkgs, ...}: {
  home.packages = [
    pkgs.emacs-custom
    pkgs.imagemagick
    pkgs.libgccjit
  ];
}
