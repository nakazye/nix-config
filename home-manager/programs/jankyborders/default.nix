{pkgs, ...}: {
  home.packages = [pkgs.jankyborders];

  launchd.agents.jankyborders = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.jankyborders}/bin/borders"
        "style=round"
        "width=9.0"
        "active_color=0xffffb6c1"
        "inactive_color=0x00000000"
        "blacklist=[\"Raycast\", \"Alfred\"]"
      ];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
