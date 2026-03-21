# アプリケーション本体はnix-darwinのhomebrew.casksで管理
# ここでは設定ファイル（karabiner.json）のみを管理
{...}: let
  # Emacs: 入力ソースをABCに切替してからプレフィクスキーを再送信
  emacsInputSourceRule = {
    description = "Emacs: 日本語入力中でもプレフィクスキーが効くようにABCへ切替";
    manipulators =
      map
      (
        {
          key,
          mod ? "control",
        }: {
          type = "basic";
          from = {
            key_code = key;
            modifiers.mandatory = [mod];
          };
          to = [
            {select_input_source.input_source_id = "com.apple.keylayout.ABC";}
            {
              key_code = key;
              modifiers = [mod];
            }
          ];
          conditions = [
            {
              type = "frontmost_application_if";
              bundle_identifiers = ["^org\\.gnu\\.Emacs$"];
            }
          ];
        }
      )
      [
        {key = "x";}
        {key = "c";}
        {key = "semicolon";}
        {
          key = "x";
          mod = "option";
        }
      ];
  };

  # MS Office: Emacsライクカーソル操作
  officeEmacsRule = {
    description = "MS Office: Emacsライクカーソル操作";
    manipulators =
      map
      (
        {
          from_key,
          to_key,
          to_mod ? [],
        }: {
          type = "basic";
          from = {
            key_code = from_key;
            modifiers.mandatory = ["control"];
          };
          to = [
            {
              key_code = to_key;
              modifiers = to_mod;
            }
          ];
          conditions = [
            {
              type = "frontmost_application_if";
              bundle_identifiers = [
                "^com\\.microsoft\\.Word$"
                "^com\\.microsoft\\.Powerpoint$"
                "^com\\.microsoft\\.Excel$"
              ];
            }
          ];
        }
      )
      [
        {
          from_key = "f";
          to_key = "right_arrow";
        }
        {
          from_key = "b";
          to_key = "left_arrow";
        }
        {
          from_key = "n";
          to_key = "down_arrow";
        }
        {
          from_key = "p";
          to_key = "up_arrow";
        }
        {
          from_key = "a";
          to_key = "left_arrow";
          to_mod = ["command"];
        }
        {
          from_key = "e";
          to_key = "right_arrow";
          to_mod = ["command"];
        }
        {
          from_key = "h";
          to_key = "delete_or_backspace";
        }
        {
          from_key = "d";
          to_key = "delete_forward";
        }
        {
          from_key = "m";
          to_key = "return_or_enter";
        }
      ];
  };

  # tmux: プレフィクスキーCtrl+]でIME offしてから再送信
  tmuxPrefixRule = {
    description = "tmux: Ctrl+]でIME offしてプレフィクスキーを再送信";
    manipulators = [
      {
        type = "basic";
        from = {
          key_code = "close_bracket";
          modifiers.mandatory = ["control"];
        };
        to = [
          {select_input_source.input_source_id = "com.apple.keylayout.ABC";}
          {
            key_code = "close_bracket";
            modifiers = ["control"];
          }
        ];
      }
    ];
  };

  # Cmd+Space: IME off (ABCに切替)
  # Raycast起動はRaycast側のホットキーを別のキーに変更すること
  cmdSpaceToAbcRule = {
    description = "Cmd+Space: IME off (ABCに切替)";
    manipulators = [
      {
        type = "basic";
        from = {
          key_code = "spacebar";
          modifiers.mandatory = ["command"];
        };
        to = [
          {select_input_source.input_source_id = "com.apple.keylayout.ABC";}
          {
            key_code = "spacebar";
            modifiers = ["command"];
          }
        ];
      }
    ];
  };

  karabinerConfig = {
    profiles = [
      {
        name = "Default";
        selected = true;
        # CapsLockもCtrlとして使えるようにする
        # （macOSシステム設定より先にKarabinerがキーを受け取るためここで管理）
        simple_modifications = [
          {
            from.key_code = "caps_lock";
            to = [{key_code = "left_control";}];
          }
          {
            from.key_code = "left_control";
            to = [{key_code = "left_control";}];
          }
        ];
        complex_modifications = {
          rules = [
            cmdSpaceToAbcRule
            tmuxPrefixRule
            emacsInputSourceRule
            officeEmacsRule
          ];
        };
      }
    ];
  };

  map = builtins.map;
in {
  xdg.configFile."karabiner/karabiner.json" = {
    text = builtins.toJSON karabinerConfig;
    force = true;
  };
}
