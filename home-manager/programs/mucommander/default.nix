{
  pkgs,
  lib,
  ...
}: {
  home.packages = [pkgs.brewCasks.mucommander];

  # muCommanderは終了時に設定ファイルを上書き保存するため、読み取り専用シンボリック
  # リンク（home.file）は使えない。書き込み可能な実体としてSanrioテーマを配置し、
  # home-manager switchの度に再適用する（宣言的ベースライン）。
  home.activation.mucommanderTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
    prefDir="$HOME/Library/Preferences/muCommander"
    run mkdir -p "$prefDir"
    run install -m 0644 ${./user_theme.xml} "$prefDir/user_theme.xml"
  '';
}
