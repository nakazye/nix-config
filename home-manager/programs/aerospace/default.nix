{pkgs, ...}: {
  home.packages = [pkgs.aerospace];

  xdg.configFile."aerospace/aerospace.toml".text = ''
    # AeroSpace設定
    # https://nikitabobko.github.io/AeroSpace/guide

    start-at-login = true
    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

    # 常に縦分割（ウィンドウが左右に並ぶ）
    default-root-container-orientation = 'horizontal'

    [gaps]
    inner.horizontal = 10
    inner.vertical = 10
    outer.left = 10
    outer.bottom = 10
    outer.top = 10
    outer.right = 10

    [mode.main.binding]
    # Ctrl+Cmd+A でaerospaceモードに入る
    ctrl-cmd-a = 'mode aerospace'

    [mode.aerospace.binding]
    # フォーカス移動
    h = 'focus left'
    j = 'focus down'
    k = 'focus up'
    l = 'focus right'

    # ウィンドウ移動
    shift-h = 'move left'
    shift-j = 'move down'
    shift-k = 'move up'
    shift-l = 'move right'

    # ワークスペース切り替え
    1 = 'workspace 1'
    2 = 'workspace 2'
    3 = 'workspace 3'
    4 = 'workspace 4'
    5 = 'workspace 5'

    # ウィンドウをワークスペースに移動
    shift-1 = 'move-node-to-workspace 1'
    shift-2 = 'move-node-to-workspace 2'
    shift-3 = 'move-node-to-workspace 3'
    shift-4 = 'move-node-to-workspace 4'
    shift-5 = 'move-node-to-workspace 5'

    # フルスクリーン
    f = 'fullscreen'

    # モードを抜ける
    esc = 'mode main'
  '';
}
