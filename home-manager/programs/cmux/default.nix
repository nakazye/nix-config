{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = [pkgs.brewCasks.cmux];

  xdg.configFile."cmux/cmux.json".text = builtins.toJSON {
    "$schema" = "https://raw.githubusercontent.com/manaflow-ai/cmux/main/web/data/cmux.schema.json";
    schemaVersion = 1;
    app = {
      sendAnonymousTelemetry = false;
    };
    terminal = {
      copyOnSelect = true;
    };
    sidebarAppearance = {
      matchTerminalBackground = true;
    };
    browser = {
      defaultSearchEngine = "kagi";
    };
    markdown = {
      # NF版はConsole系のみ配布のため端末と同じフォントを使用
      fontFamily = "PlemolJP Console NF";
    };
    shortcuts = {
      bindings = {
        # コピーモードのトグル（Emacs風チョード）。もう一度で解除
        toggleTerminalCopyMode = ["ctrl+shift+c" "ctrl+shift+t"];
        # Emacsのウィンドウ操作風（Ctrl+Shift+X 始動）
        splitDown = ["ctrl+shift+x" "2"]; # C-x 2: 下に分割
        splitRight = ["ctrl+shift+x" "3"]; # C-x 3: 右に分割
        toggleSplitZoom = ["ctrl+shift+x" "1"]; # C-x 1: 最大化トグル（≒1つに集中）
      };
    };
    workspaceColors = {
      selectionColor = "#e383a8"; # ララ（やわらかいピンク）
      notificationBadgeColor = "#f06aaa"; # マイメロ（鮮やかなピンク）
      colors = {
        # Sanrio Night パレット由来（ワークスペース表示向けに暗めに調整）
        "ハローキティ"    = "#b02840"; # #f08080 → 暗
        "マイメロディ"    = "#a02870"; # #f06aaa → 暗
        "ララ"           = "#a03060"; # #e383a8 → 暗
        "キキ"           = "#0a7080"; # #8bd0dd → 暗
        "キキ&ララ★"    = "#8a7000"; # #efc128 → 暗
        "ポムポムプリン"  = "#a06010"; # #efa42b → 暗
        "シナモロール"    = "#1858a0"; # #72b8f0 → 暗
        "クロミ"         = "#6030a0"; # #cda1dc → 暗
        "けろっぴ"       = "#1a8040"; # #91dea9 → 暗
        "けろっぴ明"     = "#5a7000"; # #bcd60a → 暗
        "ポチャッコ"     = "#006868"; # teal
        "タキシードサム"  = "#1a4068"; # navy
        "ちょこちゃん"   = "#882050"; # rose
        "ぐでたま"       = "#907000"; # amber
        "バッドばつ丸"   = "#3a3050"; # charcoal（bg-hl由来）
        "シュガーバニーズ" = "#805068"; # grayish pink
      };
    };
    automation = {
      claudeBinaryPath = "${config.home.homeDirectory}/.nix-profile/bin/claude";
      ripgrepBinaryPath = "${config.home.homeDirectory}/.nix-profile/bin/rg";
    };
  };
}
