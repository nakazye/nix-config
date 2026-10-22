{
  config,
  lib,
  pkgs,
  outputs,
  nixosVersion,
  ...
}: {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
    # 週1回（日曜3時）に古い世代を自動削除
    gc = {
      automatic = true;
      dates = "Sun 03:00";
      options = "--delete-older-than 30d";
    };
    # 週1回（日曜4時）にストアの重複ファイルをハードリンク化
    optimise = {
      automatic = true;
      dates = ["Sun 04:00"];
    };
  };

  fonts.packages = with pkgs; [
    hackgen-nf-font
    plemoljp-nf
    nerd-fonts.symbols-only
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji
  ];

  environment.systemPackages = with pkgs; [
    #    anthy
    # スタートメニューのエントリ経由でタスクバーにピン留めするため(home-managerと同じビルド)
    emacs
  ];

  # GUIアプリの.desktopをWSLgに渡し、Windowsのスタートメニューに登録する
  wsl.startMenuLaunchers = true;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  # ctranslate2などC++ヘビービルド時のOOM防止用スワップ
  swapDevices = [
    {
      device = "/var/swapfile";
      size = 8 * 1024;
    }
  ];

  system.stateVersion = nixosVersion;
}
