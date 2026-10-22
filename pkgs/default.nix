# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };

  # home-managerとNixOS(WSLのスタートメニュー登録用)で同じビルドを共有する
  emacs-custom = pkgs.emacs.override {
    withImageMagick = true;
    withNativeCompilation = true;
  };
}
