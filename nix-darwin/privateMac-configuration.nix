{pkgs, ...}: {
  imports = [./common.nix];

  system.primaryUser = "nakazye";

  # Dockに固定表示するアプリケーション
  system.defaults.dock.persistent-apps = [
    "/System/Applications/Apps.app"
  ];

  # nixpkgsに存在しない/brew-nixで問題があるアプリはHomebrewで管理
  homebrew.casks = [
    "atok"
    "bettertouchtool"
  ];
}
