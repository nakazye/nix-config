{
  pkgs,
  lib,
  systemType,
  ...
}: let
  isWSL = systemType == "wsl";
  isMac = systemType == "privateMac" || systemType == "businessMac";
  isLinux = !isMac;
in {
  programs.nixvim = {
    enable = true;

    # クリップボード連携
    clipboard = {
      register = "unnamedplus";
      providers = {
        # Mac: pbcopy/pbpasteを使用（追加パッケージ不要）
        # 通常Linux (X11): xclipを使用
        xclip.enable = isLinux && !isWSL;
        # WSL: WSLgのWayland対応でwl-copyを使用
        wl-copy.enable = isWSL;
      };
    };

    # カラースキーム
    colorscheme = "cosme";
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "cosme-vim";
        src = pkgs.fetchFromGitHub {
          owner = "beikome";
          repo = "cosme.vim";
          rev = "master";
          hash = "sha256-ZKROIe/NEdTvdwzEN1e5V+ZIOhLws9jbSR74t7Hkugk=";
        };
      })
    ];

    # 文字コード設定
    opts = {
      encoding = "utf-8";
      fileencoding = "utf-8";
      fileencodings = "ucs-bom,utf-8,euc-jp,cp932";
      fileformats = "unix,dos,mac";
      ambiwidth = "single";

      # バックアップ等ファイル設定
      swapfile = false;
      backup = false;
      undofile = false;
      writebackup = true;
      hidden = true;

      # マウス操作を無効
      mouse = "";

      # 行番号表示
      number = true;
      # 現在の行を強調表示
      cursorline = true;
      # スマートインデント
      smartindent = true;
      # ビープ音を可視化
      visualbell = true;
      # 対応括弧表示
      showmatch = true;
      # ステータスラインを常に表示
      laststatus = 2;
      # コマンドラインでタブ補完
      wildmenu = true;
      # 不可視文字表示
      list = true;
      listchars = {
        tab = "»-";
        trail = "･";
        eol = "↲";
        extends = "»";
        precedes = "«";
        nbsp = "%";
      };
      # tabを半角スペースに
      expandtab = true;
      # tab表示幅
      tabstop = 2;
      shiftwidth = 2;

      # 小文字で検索した場合は大文字もヒット
      ignorecase = true;
      # 大文字含みで検索した場合は区別して検索
      smartcase = true;
      # インクリメンタルサーチ
      incsearch = true;
      # 検索で最後までいったら最初に戻る
      wrapscan = true;
      # 検索語をハイライト
      hlsearch = true;
    };

    # キーマップ設定
    keymaps = let
      # インサートモードをEmacsライクに
      emacsInsertKeys = {
        "<C-d>" = "<Del>";
        "<C-h>" = "<BS>";
        "<C-a>" = "<Home>";
        "<C-e>" = "<End>";
        "<C-p>" = "<Up>";
        "<C-n>" = "<Down>";
        "<C-f>" = "<Right>";
        "<C-b>" = "<Left>";
      };
    in
      # ESC連打でハイライト解除
      [
        {
          mode = "n";
          key = "<Esc><Esc>";
          action = ":nohlsearch<CR><Esc>";
        }
      ]
      # Emacsキーバインド
      ++ lib.mapAttrsToList (key: action: {
        mode = "i";
        inherit key action;
        options.noremap = true;
      }) emacsInsertKeys
      # Telescope
      ++ [
        {
          mode = "n";
          key = "<C-x>b";
          action = "<cmd>Telescope buffers<cr>";
          options.noremap = true;
        }
        {
          mode = "n";
          key = "<C-x><C-f>";
          action = "<cmd>Telescope file_browser<cr>";
          options.noremap = true;
        }
        # ToggleTerm: ターミナルからノーマルモードへ
        {
          mode = "t";
          key = "<ESC><ESC>";
          action = "<C-\\><C-n>";
          options.noremap = true;
        }
      ];

    # プラグイン設定
    plugins = {
      # アイコン（Telescope等で使用）
      web-devicons.enable = true;

      # キーバインドヘルプ表示
      which-key.enable = true;

      # Treesitter
      treesitter = {
        enable = true;
      };

      # Telescope
      telescope = {
        enable = true;
        extensions.file-browser.enable = true;
        settings.defaults.mappings.i."<F1>" = "which_key";
      };

      # ToggleTerm
      toggleterm = {
        enable = true;
        settings = {
          open_mapping = "[[<c-t>]]";
          direction = "float";
        };
      };
    };
  };
}
