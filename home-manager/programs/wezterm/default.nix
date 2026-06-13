{pkgs, ...}: {
  programs.wezterm = {
    enable = true;
    # シェル統合を無効化（他のターミナルでもロードされて遅延の原因になる）
    enableZshIntegration = false;
    enableBashIntegration = false;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()
      config.automatically_reload_config = true

      config.font = wezterm.font('PlemolJP Console NF')
      config.font_size = 18.0
      config.use_ime = true
      config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'
      config.enable_tab_bar = false
      config.disable_default_key_bindings = true

      -- Sanrio Night (dark)
      config.colors = {
        foreground    = '#f9e9f2',
        background    = '#1b1118',
        cursor_bg     = '#e383a8',
        cursor_fg     = '#1b1118',
        cursor_border = '#e383a8',
        selection_fg  = '#f9e9f2',
        selection_bg  = '#3a2432',
        scrollbar_thumb = '#3a2432',
        split         = '#3a2432',
        ansi = {
          '#271a22',  -- black    bg-alt
          '#f08080',  -- red      Hello Kitty
          '#91dea9',  -- green    けろっぴ
          '#efc128',  -- yellow   キキ&ララ (星)
          '#72b8f0',  -- blue     シナモロール
          '#e383a8',  -- magenta  ララ (LTS ピンク)
          '#8bd0dd',  -- cyan     キキ (LTS 水色)
          '#c8a4bc',  -- white    fg-dim
        },
        brights = {
          '#8a7082',  -- bright black    gray
          '#f06aaa',  -- bright red      マイメロ
          '#bcd60a',  -- bright green    けろっぴ (明)
          '#efa42b',  -- bright yellow   ポムポムプリン
          '#cda1dc',  -- bright blue     クロミ
          '#f06aaa',  -- bright magenta  マイメロ
          '#8bd0dd',  -- bright cyan     キキ
          '#f9e9f2',  -- bright white    fg
        },
      }

      config.keys = {
        {
          key = 'v',
          mods = 'CMD',
          action = wezterm.action.PasteFrom 'Clipboard',
        },
        {
          key = 'c',
          mods = 'CMD',
          action = wezterm.action.CopyTo 'Clipboard',
        },
      }

      return config
    '';
  };
}
