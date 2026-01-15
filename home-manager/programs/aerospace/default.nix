{pkgs, ...}: {
  home.packages = [pkgs.aerospace];

  xdg.configFile."aerospace/aerospace.toml".text = ''
    # AeroSpace設定
    # https://nikitabobko.github.io/AeroSpace/guide

    start-at-login = true
    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

    [gaps]
    inner.horizontal = 10
    inner.vertical = 10
    outer.left = 10
    outer.bottom = 10
    outer.top = 10
    outer.right = 10

    [mode.main.binding]
    # ワークスペース切り替え (Ctrl+Cmd+数字)
    ctrl-cmd-1 = 'workspace 1'
    ctrl-cmd-2 = 'workspace 2'
    ctrl-cmd-3 = 'workspace 3'
    ctrl-cmd-4 = 'workspace 4'
    ctrl-cmd-5 = 'workspace 5'

    # ウィンドウをワークスペースに移動 (Ctrl+Cmd+Shift+数字)
    ctrl-cmd-shift-1 = 'move-node-to-workspace 1'
    ctrl-cmd-shift-2 = 'move-node-to-workspace 2'
    ctrl-cmd-shift-3 = 'move-node-to-workspace 3'
    ctrl-cmd-shift-4 = 'move-node-to-workspace 4'
    ctrl-cmd-shift-5 = 'move-node-to-workspace 5'

    # フォーカス移動 (Ctrl+Cmd+hjkl)
    ctrl-cmd-h = 'focus left'
    ctrl-cmd-j = 'focus down'
    ctrl-cmd-k = 'focus up'
    ctrl-cmd-l = 'focus right'

    # ウィンドウ移動 (Ctrl+Cmd+Shift+hjkl)
    ctrl-cmd-shift-h = 'move left'
    ctrl-cmd-shift-j = 'move down'
    ctrl-cmd-shift-k = 'move up'
    ctrl-cmd-shift-l = 'move right'

    # レイアウト
    ctrl-cmd-slash = 'layout tiles horizontal vertical'
    ctrl-cmd-comma = 'layout accordion horizontal vertical'
    ctrl-cmd-f = 'fullscreen'

    # サイズ変更
    ctrl-cmd-minus = 'resize smart -50'
    ctrl-cmd-equal = 'resize smart +50'

    # ウィンドウの結合 (join-with)
    ctrl-cmd-shift-down = 'join-with down'
    ctrl-cmd-shift-up = 'join-with up'
    ctrl-cmd-shift-left = 'join-with left'
    ctrl-cmd-shift-right = 'join-with right'
  '';
}
