{...}: {
  # cmux が内蔵する Ghostty のターミナル設定（~/.config/ghostty/config）。
  # フォント・配色・端末キー再マップは cmux.json では扱えないため Ghostty 側で管理する。
  xdg.configFile."ghostty/config".text = ''
    # ── フォント ──
    font-family = "PlemolJP Console NF"
    font-size = 16
    # macOSの細字レンダリング対策（線を太らせて視認性を上げる）
    # strengthで太らせ量を調整（0〜255。既定=最大で太すぎるため控えめに）
    font-thicken = true
    font-thicken-strength = 20
    grapheme-width-method = unicode

    # ── Sanrio Night カラースキーム（~/.config/emacs/sanrio-theme-preview.html 由来）──
    background = #1b1118
    foreground = #f9e9f2
    cursor-color = #e383a8
    cursor-text = #1b1118
    selection-background = #3a2432
    selection-foreground = #f9e9f2

    # ANSI 16色 (0-7 通常 / 8-15 明色)
    palette = 0=#271a22
    palette = 1=#f08080
    palette = 2=#91dea9
    palette = 3=#efc128
    palette = 4=#72b8f0
    palette = 5=#f06aaa
    palette = 6=#8bd0dd
    palette = 7=#c8a4bc
    palette = 8=#8a7082
    palette = 9=#efa42b
    palette = 10=#bcd60a
    palette = 11=#efc128
    palette = 12=#72b8f0
    palette = 13=#cda1dc
    palette = 14=#8bd0dd
    palette = 15=#f9e9f2

    # ── キー再マップ: Ctrl+I → Tab, Ctrl+M → Enter ──
    keybind = ctrl+i=text:\t
    keybind = ctrl+m=text:\r
  '';
}
