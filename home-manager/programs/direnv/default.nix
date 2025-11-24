{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
    # パフォーマンス最適化
    config = {
      global = {
        warn_timeout = "0s";      # タイムアウト警告を無効化
        hide_env_diff = true;     # 環境変数の差分表示を無効化
      };
    };
    # ログを抑制して高速化
    stdlib = ''
      export DIRENV_LOG_FORMAT=""
    '';
  };
}
