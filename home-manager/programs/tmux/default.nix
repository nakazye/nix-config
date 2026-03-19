{...}: {
  programs.tmux = {
    enable = true;
    prefix = "C-]";
    keyMode = "emacs";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;
    extraConfig = ''
      # Emacsライクなpane操作 (C-x 0/1/2/3/o/b に対応)
      bind 0 kill-pane
      bind 1 break-pane
      bind 2 split-window -v
      bind 3 split-window -h
      bind o select-pane -t :.+
      bind b choose-window

      # 新しいウィンドウを作成（tmuxデフォルト: c）
      bind c new-window

      # ペースト
      bind-key C-y paste-buffer

      # ウィンドウを閉じる
      bind k kill-window
      unbind &

      # paneリサイズ
      bind -r C-h resize-pane -L 5
      bind -r C-j resize-pane -D 5
      bind -r C-k resize-pane -U 5
      bind -r C-l resize-pane -R 5
    '';
  };
}
