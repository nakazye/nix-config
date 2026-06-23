# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # direnv: macOSサンドボックスでfishテストがSIGKILLされるためcheckPhaseをスキップ
    # 追跡: https://github.com/nixos/nixpkgs/issues/475999
    direnv = prev.direnv.overrideAttrs (_oldAttrs: {
      doCheck = false;
    });

    # oletools: 会社のウイルススキャンが誤検知するためインストール禁止。
    # top-level と全Pythonパッケージセットの両方で評価時にthrowさせる。
    oletools = throw "oletools はインストール禁止です（会社のウイルススキャンが誤検知するため）。CLAUDE.md参照。";
    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (_pyfinal: _pyprev: {
          oletools = throw "oletools はインストール禁止です（会社のウイルススキャンが誤検知するため）。CLAUDE.md参照。";
        })
      ];
  };
}
