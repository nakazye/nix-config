{pkgs, ...}: {
  imports = [ ./common.nix ];

  system.primaryUser = "nakazye";

  # Dockに固定表示するアプリケーション
  system.defaults.dock.persistent-apps = [
    "/System/Applications/Apps.app"
  ];

  homebrew.casks = [
    "atok"
    "slack"
    "discord"
    "orion"
    "raycast"
    "bettertouchtool"
    "doll"
    "jordanbaird-ice"
    # エラー出るので、一旦普通に入れる方向で
    # "parallels"
    "alt-tab"
    # JetBrains
    "intellij-idea"
    "pycharm"
    "webstorm"
    "datagrip"
  ];
}
