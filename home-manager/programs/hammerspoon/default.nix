# アプリケーション本体はnix-darwinのhomebrew.casksで管理
# ここでは設定ファイル（init.lua）とログイン時の起動のみを管理
{pkgs, ...}: let
  hsApp = "/Applications/Hammerspoon.app";
  hsCli = "${hsApp}/Contents/Frameworks/hs/hs";

  # ログイン時に起動し、少し待ってから1回だけリロードする。
  # 後から起動するRaycast/AeroSpace等にホットキーを奪われることがあるため、
  # 他のログイン項目が揃った頃にリロードしてホットキーを登録し直す
  launchAndReload = pkgs.writeShellScript "hammerspoon-launch-and-reload" ''
    set -u

    /usr/bin/open -g -a "${hsApp}"

    # hs.ipcが応答するまで待つ（init.lua読み込み完了の目安）
    deadline=$(( $(date +%s) + 60 ))
    until "${hsCli}" -q -t 2 -c 'return true' >/dev/null 2>&1; do
      if [ "$(date +%s)" -ge "$deadline" ]; then
        echo "hammerspoon: IPCの応答待ちがタイムアウトしました" >&2
        exit 1
      fi
      sleep 1
    done

    sleep 20

    # 直接hs.reload()するとIPC応答前にLua環境が破棄されるため、タイマーで遅延実行
    "${hsCli}" -q -c 'hs.timer.doAfter(0.5, hs.reload)'
  '';
in {
  launchd.agents.hammerspoon = {
    enable = true;
    config = {
      ProgramArguments = ["${launchAndReload}"];
      RunAtLoad = true;
      KeepAlive = false;
    };
  };

  home.file.".hammerspoon/init.lua".text = ''
    -- launchd agentからhsコマンドでリロードするためにIPCを有効化
    require("hs.ipc")

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

    -- 実際にキー入力を受けているアプリのbundle IDを返す。
    -- RaycastはLSUIElement(メニューバー常駐)アプリで検索パネルが非アクティブ化
    -- パネルのため、NSWorkspaceのfrontmostApplicationでは検出できない。
    -- アクセシビリティのAXFocusedApplicationで判定し、失敗時はfrontmostにフォールバック。
    local function frontBundleID()
      local ok, sysWide = pcall(hs.axuielement.systemWideElement)
      if ok and sysWide then
        local focusedApp = sysWide:attributeValue("AXFocusedApplication")
        if focusedApp then
          local pid = focusedApp:pid()
          local app = pid and hs.application.applicationForPID(pid)
          if app then return app:bundleID() or "" end
        end
      end
      local front = hs.application.frontmostApplication()
      return front and front:bundleID() or ""
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

    -- === Emacs用ホットキー（常時有効） ===

    local emacsPrefixes = {
      {mods={"ctrl"}, key="x"},
      {mods={"ctrl"}, key="c"},
      {mods={"ctrl"}, key=";"},
      {mods={"alt"},  key="x"},
    }
    for _, p in ipairs(emacsPrefixes) do
      local mods, key = p.mods, p.key
      local hk = bindWithReentry(mods, key, function()
        switchToABC()
        hs.eventtap.keyStroke(mods, key)
      end)
      hk:enable()
    end

    -- === アプリ別キーリマップ（内部でフロントアプリを確認） ===

    -- 対象アプリのbundle IDリスト。複数リストを1つの集合にまとめる
    local office  = {"com.microsoft.Word", "com.microsoft.Powerpoint", "com.microsoft.Excel"}
    local raycast = {"com.raycast.macos"}

    local function bundleSet(...)
      local set = {}
      for _, list in ipairs({...}) do
        for _, bid in ipairs(list) do set[bid] = true end
      end
      return set
    end

    -- apps: そのリマップを適用するアプリの集合。非対象アプリでは元のCtrl+キーを再送信
    local mappings = {
      {from="f", to="right",         toMods={},      apps=bundleSet(office)},
      {from="b", to="left",          toMods={},      apps=bundleSet(office)},
      {from="n", to="down",          toMods={},      apps=bundleSet(office)},
      {from="p", to="up",            toMods={},      apps=bundleSet(office)},
      {from="a", to="left",          toMods={"cmd"}, apps=bundleSet(office)},
      {from="e", to="right",         toMods={"cmd"}, apps=bundleSet(office)},
      {from="h", to="delete",        toMods={},      apps=bundleSet(office)},
      {from="d", to="forwarddelete", toMods={},      apps=bundleSet(office)},
      {from="m", to="return",        toMods={},      apps=bundleSet(office, raycast)},
      {from="g", to="escape",        toMods={},      apps=bundleSet(raycast)},
    }
    for _, m in ipairs(mappings) do
      local from, toMods, to, apps = m.from, m.toMods, m.to, m.apps
      local hk = bindWithReentry({"ctrl"}, from, function()
        if apps[frontBundleID()] then
          hs.eventtap.keyStroke(toMods, to)
        else
          hs.eventtap.keyStroke({"ctrl"}, from)
        end
      end)
      hk:enable()
    end
  '';
}
