{pkgs, ...}: {
  home.packages = [
    pkgs.brewCasks.notunes
  ];

  # ログイン時に自動起動
  launchd.agents.notunes = {
    enable = true;
    config = {
      ProgramArguments = ["${pkgs.brewCasks.notunes}/Applications/noTunes.app/Contents/MacOS/noTunes"];
      RunAtLoad = true;
      KeepAlive = false;
    };
  };
}
