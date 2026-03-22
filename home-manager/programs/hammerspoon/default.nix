# アプリケーション本体はnix-darwinのhomebrew.casksで管理
# ここでは設定ファイル（init.lua）のみを管理
{...}: {
  home.file.".hammerspoon/init.lua".text = ''
    -- CapsLock→Ctrlはnix-darwinのsystem.keyboard.remapCapsLockToControlで管理

    local function switchToABC()
      hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
    end

    -- ホットキーを一時無効化して再送信する（無限ループ防止）
    local function bindWithReentry(mods, key, fn)
      local hk
      hk = hs.hotkey.new(mods, key, function()
        hk:disable()
        fn()
        hs.timer.doAfter(0.05, function() hk:enable() end)
      end)
      return hk
    end

    -- === 常時有効なグローバルホットキー ===

    -- Cmd+Space: ABC切替してから再送信（IME off）
    -- Raycast起動は別のキーに変更しておくこと
    local cmdSpaceHk = bindWithReentry({"cmd"}, "space", function()
      switchToABC()
      hs.eventtap.keyStroke({"cmd"}, "space")
    end)
    cmdSpaceHk:enable()

    -- tmux: Ctrl+] でABC切替してから再送信
    local tmuxHk = bindWithReentry({"ctrl"}, "]", function()
      switchToABC()
      hs.eventtap.keyStroke({"ctrl"}, "]")
    end)
    tmuxHk:enable()

    -- === Emacs用ホットキー（常時有効、内部でフロントアプリを確認） ===

    local emacsPrefixes = {
      {mods={"ctrl"}, key="x"},
      {mods={"ctrl"}, key="c"},
      {mods={"ctrl"}, key=";"},
      {mods={"alt"},  key="x"},
    }
    for _, p in ipairs(emacsPrefixes) do
      local mods, key = p.mods, p.key
      local hk = bindWithReentry(mods, key, function()
        local app = hs.application.frontmostApplication()
        if app and app:bundleID() == "org.gnu.Emacs" then
          switchToABC()
        end
        hs.eventtap.keyStroke(mods, key)
      end)
      hk:enable()
    end

    -- === MS Office用ホットキー（常時有効、内部でフロントアプリを確認） ===

    local officeBundle = {
      ["com.microsoft.Word"]       = true,
      ["com.microsoft.Powerpoint"] = true,
      ["com.microsoft.Excel"]      = true,
    }

    local officeMappings = {
      {from="f", to="right",         toMods={}},
      {from="b", to="left",          toMods={}},
      {from="n", to="down",          toMods={}},
      {from="p", to="up",            toMods={}},
      {from="a", to="left",          toMods={"cmd"}},
      {from="e", to="right",         toMods={"cmd"}},
      {from="h", to="delete",        toMods={}},
      {from="d", to="forwarddelete", toMods={}},
      {from="m", to="return",        toMods={}},
    }
    for _, m in ipairs(officeMappings) do
      local from, toMods, to = m.from, m.toMods, m.to
      local hk = hs.hotkey.new({"ctrl"}, from, function()
        local app = hs.application.frontmostApplication()
        local bid = app and app:bundleID() or ""
        if officeBundle[bid] then
          hs.eventtap.keyStroke(toMods, to)
        else
          hs.eventtap.keyStroke({"ctrl"}, from)
        end
      end)
      hk:enable()
    end
  '';
}
