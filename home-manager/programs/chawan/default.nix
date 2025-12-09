{pkgs, ...}: {
  home.packages = with pkgs; [
    chawan
  ];

  xdg.configFile."chawan/config.toml".text = ''
    [buffer]
    images = true
    # Cookieを保存
    cookie = "save"
    # 閲覧履歴を保存
    history = true

    [input]
    # マウス操作を有効化
    use-mouse = true

    [network]
    # HTTPSを優先
    prepend-scheme = "https://"

    [encoding]
    # 日本語エンコーディング対応
    document-charset = ["utf-8", "shift_jis", "euc-jp", "iso-2022-jp"]
  '';
}
