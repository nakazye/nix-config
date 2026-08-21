{
  config,
  lib,
  pkgs,
  ...
}: let
  tokenFile = "${config.home.homeDirectory}/.local/share/rclone-secrets/dropbox-token";

  # 1Password上のトークンの場所。Vault名が異なる場合はここを変更する
  tokenRef = "op://Private/rclone-dropbox/token";

  # switch時にトークンを1Passwordから取得する。既に存在すれば何もしない
  # （再取得したい場合は tokenFile を消してから switch する）
  materializeToken = pkgs.writeShellScript "rclone-materialize-token" ''
    set -euo pipefail

    tokenFile="${tokenFile}"
    if [ -s "$tokenFile" ]; then
      exit 0
    fi

    # WSLではWindows側のop.exeを使う。Linux版のデスクトップアプリ連携はPolKit前提で
    # Windowsの1Passwordとは繋がらないため
    # home-manager activationスクリプトはPATHを最小限に絞るため、
    # home.packagesで入れたopは~/.nix-profile/binを明示的に見に行く必要がある
    op=""
    for candidate in \
      op \
      "$HOME/.nix-profile/bin/op" \
      /usr/local/bin/op \
      "/mnt/c/Program Files/1Password CLI/op.exe" \
      "/mnt/c/Program Files/1Password/app/8/op.exe"; do
      if command -v "$candidate" >/dev/null 2>&1; then
        op="$candidate"
        break
      fi
    done

    # 取得できなくてもswitch自体は止めない（rclone以外の設定を巻き込まないため）
    if [ -z "$op" ]; then
      echo "rclone: 1Password CLI が見つからないため $tokenFile を作成できません" >&2
      exit 0
    fi

    install -d -m700 "$(dirname "$tokenFile")"
    umask 077
    if ! "$op" read --no-newline "${tokenRef}" | tr -d '\r' > "$tokenFile.tmp"; then
      rm -f "$tokenFile.tmp"
      echo "rclone: ${tokenRef} の取得に失敗しました" >&2
      exit 0
    fi
    mv -f "$tokenFile.tmp" "$tokenFile"
  '';
in {
  programs.rclone = {
    enable = true;

    # config は非秘密の接続情報のみ（Nixストアは全ユーザー可読）
    # 秘密情報は secrets に「ファイルパス」を書く。中身はサービス起動時に読まれる
    remotes.dropbox = {
      config.type = "dropbox";
      secrets.token = tokenFile;
    };
  };

  # rclone.confを生成するサービスが動く前にトークンを用意する
  home.activation.rcloneToken =
    lib.hm.dag.entryBetween
    [
      (
        if pkgs.stdenv.hostPlatform.isDarwin
        then "setupLaunchAgents"
        else "reloadSystemd"
      )
    ]
    ["writeBoundary"]
    ''
      run ${materializeToken}
    '';
}
