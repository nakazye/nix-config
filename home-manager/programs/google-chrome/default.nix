{pkgs-unstable ? null, ...}: {
  # brew-nixではハッシュ不一致エラーのためnixpkgs-unstableを使用
  home.packages =
    if pkgs-unstable != null
    then [pkgs-unstable.google-chrome]
    else [];
}
