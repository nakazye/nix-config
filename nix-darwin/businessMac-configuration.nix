# UID/GIDが使われている場合の対応
#
# 1,GID/UIDは以下で変えれる
# export NIX_BUILD_GROUP_ID=4000
# export NIX_FIRST_BUILD_UID=4001
# sudo sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
#
# 2,一方、UIDは変えるにしても再設定が必要そう
# curl --proto '=https' --tlsv1.2 -sSf -L https://github.com/NixOS/nix/raw/master/scripts/sequoia-nixbld-user-migration.sh | bash -
#
# 3,configに、使ってるUIDとGIDの指定が必要
#   ids.uids.nixbld = 351;
#   ids.gids.nixbld = 4000;
#
{pkgs, ...}:
let
  # sudo実行時でも元のユーザー名を取得
  username = let
    sudoUser = builtins.getEnv "SUDO_USER";
    currentUser = builtins.getEnv "USER";
  in
    if sudoUser != "" then sudoUser else currentUser;
in
{
  imports = [ ./common.nix ];

  system.primaryUser = username;

  homebrew.casks = [
    "atok"
    "slack"
    "orion"
    "raycast"
    "bettertouchtool"
    "doll"
    "jordanbaird-ice"
    "alt-tab"
    # JetBrains
    "intellij-idea"
    "pycharm"
    "webstorm"
    "datagrip"
    # プロジェクト特有
    "aws-vpn-client"
    "google-chrome"
  ];

  # 企業環境での既存ID競合対応
  ids.uids.nixbld = 351;
  ids.gids.nixbld = 4000;
}
