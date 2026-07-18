{
  pkgs,
  lib,
  ...
}: let
  # 「外観」= Look & Feel（ウィンドウ枠/ボタン/メニュー等のSwing外観）。
  # 選択肢: com.formdev.flatlaf.FlatDarculaLaf / FlatDarkLaf / FlatLightLaf /
  #   FlatIntelliJLaf、org.violetlib.aqua.AquaLookAndFeel、com.apple.laf.AquaLookAndFeel など。
  lookAndFeel = "com.formdev.flatlaf.FlatDarculaLaf";

  # preferences.xmlが未生成の環境向けの種ファイル（最小構成。残りはアプリが既定値で補完）。
  seedPrefs = pkgs.writeText "mucommander-preferences.xml" ''
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <preferences>
        <lookAndFeel>${lookAndFeel}</lookAndFeel>
    </preferences>
  '';
in {
  home.packages = [pkgs.brewCasks.mucommander];

  # muCommanderは終了時に設定ファイルを上書き保存するため、読み取り専用シンボリック
  # リンク（home.file）は使えない。書き込み可能な実体として配置し、home-manager
  # switchの度に再適用する（宣言的ベースライン）。
  home.activation.mucommanderTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
    prefDir="$HOME/Library/Preferences/muCommander"
    prefFile="$prefDir/preferences.xml"
    run mkdir -p "$prefDir"

    # テーマ（ファイル一覧の配色/フォント）
    run install -m 0644 ${./user_theme.xml} "$prefDir/user_theme.xml"

    # 外観（Look & Feel）: preferences.xmlはアプリ管理のため該当値のみ書き換える。
    # BSD/GNU sedの -i 差異を避けるため一時ファイル経由で置換する。
    if [ -f "$prefFile" ] && grep -q '<lookAndFeel>' "$prefFile"; then
      tmpFile="$(mktemp)"
      sed -E "s#<lookAndFeel>.*</lookAndFeel>#<lookAndFeel>${lookAndFeel}</lookAndFeel>#" "$prefFile" > "$tmpFile"
      run install -m 0644 "$tmpFile" "$prefFile"
      run rm -f "$tmpFile"
    else
      run install -m 0644 ${seedPrefs} "$prefFile"
    fi
  '';
}
