{
  config,
  lib,
  pkgs,
  ...
}: let
  appPlist = "$HOME/${config.targets.darwin.copyApps.directory}/AltTab.app/Contents/Info.plist";
  readVersion = ''/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "${appPlist}" 2>/dev/null || true'';
in {
  home.packages = [pkgs.brewCasks.alt-tab];

  # 起動中にcopyAppsでバンドルが新バージョンに差し替わると、
  # 旧プロセスと新リソースが食い違ってCmd+Tabで選択が進まなくなる。
  # バージョンが変わった場合のみ、起動中のAltTabを再起動する
  home.activation.altTabVersionBefore = lib.hm.dag.entryBefore ["copyApps"] ''
    altTabVersionBefore="$(${readVersion})"
  '';

  home.activation.altTabRestart = lib.hm.dag.entryAfter ["copyApps"] ''
    altTabVersionAfter="$(${readVersion})"
    if [[ -n "$altTabVersionBefore" && "$altTabVersionBefore" != "$altTabVersionAfter" ]] \
      && /usr/bin/pgrep -xq AltTab; then
      echo "restarting AltTab ($altTabVersionBefore -> $altTabVersionAfter)..." >&2
      run /usr/bin/pkill -x AltTab
      # 終了を待ってから起動しないと、openが旧プロセスを前面化するだけになる
      for _ in {1..50}; do
        /usr/bin/pgrep -xq AltTab || break
        sleep 0.1
      done
      run /usr/bin/open -g "$HOME/${config.targets.darwin.copyApps.directory}/AltTab.app"
    fi
  '';
}
