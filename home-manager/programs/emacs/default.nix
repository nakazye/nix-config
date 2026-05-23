{pkgs, ...}: {
  home.packages = [
    (pkgs.emacs.override {
      withImageMagick = true;
      withNativeCompilation = true;
    })
    pkgs.imagemagick
    pkgs.libgccjit
  ];
}
