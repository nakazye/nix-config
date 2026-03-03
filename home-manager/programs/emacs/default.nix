{pkgs, ...}: {
  home.packages = [
    (pkgs.emacs.override {
      withImageMagick = true;
    })
    pkgs.imagemagick
  ];
}
