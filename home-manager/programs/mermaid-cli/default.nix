{pkgs, ...}: let
  chromePath =
    if pkgs.stdenv.isDarwin
    then "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    else "${pkgs.chromium}/bin/chromium";
  mmdc-wrapped = pkgs.writeShellScriptBin "mmdc" ''
    export PUPPETEER_EXECUTABLE_PATH="${chromePath}"
    exec ${pkgs.mermaid-cli}/bin/mmdc "$@"
  '';
in {
  home.packages = [mmdc-wrapped];
}
