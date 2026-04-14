{lib, ...}: {
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
    # パフォーマンス最適化
    config = {
      global = {
        warn_timeout = "0s"; # タイムアウト警告を無効化
        hide_env_diff = true; # 環境変数の差分表示を無効化
      };
    };
    # ログを抑制して高速化
    stdlib = ''
      export DIRENV_LOG_FORMAT=""
    '';
  };

  # direnv 2.37.1: macOSサンドボックスでfishテストがSIGKILLされるため
  # overlays/default.nix で doCheck=false にしている（nixpkgs#475999）
  # 新バージョンが出たら overlay を削除できるか確認すること
  home.activation.direnvWorkaroundNotice = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo ""
    echo "NOTE: direnv は doCheck=false でビルドされています (fish test SIGKILL 回避)"
    echo "      解消確認後は overlays/default.nix の direnv override を削除してください"
    echo ""
  '';
}
