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

      config.font = wezterm.font('HackGen Console NF')
      config.font_size = 18.0
      config.use_ime = true
      config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'
      config.enable_tab_bar = false
      config.disable_default_key_bindings = true

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
