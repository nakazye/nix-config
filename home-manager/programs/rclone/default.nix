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

  noteMountPoint = "${config.home.homeDirectory}/note/private";

  # macOSにはLinuxと違いFUSEが標準搭載されておらず、rclone mount(FUSE)を
  # 使うにはmacFUSE等の追加インストールとシステム拡張の承認が要る。
  # それを避けるため、macOSでは rclone serve nfs を使いローカルのNFS
  # クライアントでマウントする（NFSはmacOS標準サポートのため追加導入不要）
  noteNfsPort = 34049;

  # launchdにはsystemdのAfter=/Requires=に相当するユニット間の依存関係が
  # ないため、rclone serve nfsがポートをlistenし始めるまでポーリングで
  # 待ってからmount_nfsを実行する
  mountNoteNfs = pkgs.writeShellScript "rclone-mount-note-nfs" ''
    set -euo pipefail

    mountPoint="${noteMountPoint}"
    port="${toString noteNfsPort}"

    if /sbin/mount | grep -q " on $mountPoint "; then
      exit 0
    fi

    deadline=$(( $(date +%s) + 60 ))
    while ! /usr/bin/nc -z -w1 127.0.0.1 "$port"; do
      if [ "$(date +%s)" -ge "$deadline" ]; then
        echo "rclone: NFSサーバ(127.0.0.1:$port)への接続待ちがタイムアウトしました" >&2
        exit 1
      fi
      sleep 1
    done

    mkdir -p "$mountPoint"
    exec /sbin/mount_nfs -o vers=3,tcp,port=$port,mountport=$port,noresvport,soft,rsize=131072,wsize=131072,actimeo=120 \
      127.0.0.1:/ "$mountPoint"
  '';
in {
  programs.rclone = {
    enable = true;

    # config は非秘密の接続情報のみ（Nixストアは全ユーザー可読）
    # 秘密情報は secrets に「ファイルパス」を書く。中身はサービス起動時に読まれる
    remotes.dropbox = {
      config.type = "dropbox";
      secrets.token = tokenFile;

      # Linux: カーネル標準のFUSEでそのままマウントできる
      mounts = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        "Private/note/private" = {
          enable = true;
          mountPoint = noteMountPoint;
        };
      };

      # macOS: FUSEの代わりにNFSサーバとして配信する（下のlaunchd.agentsで
      # このNFSサーバを標準NFSクライアントでマウントする）
      serve = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        "Private/note/private" = {
          enable = true;
          protocol = "nfs";
          options.addr = "127.0.0.1:${toString noteNfsPort}";
        };
      };
    };
  };

  launchd.agents = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    rclone-mount-note-nfs = {
      enable = true;
      config = {
        ProgramArguments = [(toString mountNoteNfs)];
        RunAtLoad = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/rclone/mount-note-nfs.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/rclone/mount-note-nfs.err.log";
      };
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
