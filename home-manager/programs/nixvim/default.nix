{
  pkgs,
  lib,
  ...
}: {
  programs.neovim = {
    enable = true;

    extraLuaConfig = ''
      -- 文字コード設定
      vim.opt.encoding = 'utf-8'
      vim.scriptencoding = 'utf-8'
      vim.opt.fileencoding = 'utf-8'
      vim.opt.fileencodings = 'ucs-bom,utf-8,euc-jp,cp932'
      vim.opt.fileformats = 'unix,dos,mac'
      vim.opt.ambiwidth = 'single'

      -- バックアップ等ファイル設定
      vim.opt.swapfile = false
      vim.opt.backup = false
      vim.opt.undofile = false
      vim.opt.writebackup = true
      vim.opt.hidden = true

      -- マウス操作を無効
      vim.opt.mouse = ""

      -- 行番号表示
      vim.opt.number = true
      -- 現在の行を強調表示
      vim.opt.cursorline = true
      -- スマートインデント
      vim.opt.smartindent = true
      -- ビープ音を可視化
      vim.opt.visualbell = true
      -- 対応括弧表示
      vim.opt.showmatch = true
      -- ステータスラインを常に表示
      vim.opt.laststatus = 2
      -- コマンドラインでタブ補完
      vim.opt.wildmenu = true
      -- シンタックスハイライトの有効化
      vim.cmd('syntax on')
      -- 不可視文字表示
      vim.opt.list = true
      vim.opt.listchars={tab = '»-', trail = '･', eol = '↲', extends = '»', precedes = '«',nbsp = '%'}
      -- tabを半角スペースに
      vim.opt.expandtab = true
      -- tab表示幅
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2

      -- 小文字で検索した場合は大文字もヒット
      vim.opt.ignorecase = true
      -- 大文字含みで検索した場合は区別して検索
      vim.opt.smartcase = true
      -- インクリメンタルサーチ
      vim.opt.incsearch = true
      -- 検索で最後までいったら最初に戻る
      vim.opt.wrapscan = true
      -- 検索語をハイライト
      vim.opt.hlsearch = true
      -- ESC連打でハイライト解除
      vim.keymap.set('n', '<Esc><Esc>', ':nohlsearch<CR><Esc>', {remap = true})

      -- インサートモードをEmacsライクに
      vim.keymap.set('i', '<C-d>', '<Del>', { remap = false })
      vim.keymap.set('i', '<C-h>', '<BS>', { remap = false })
      vim.keymap.set('i', '<C-a>', '<home>', { remap = false })
      vim.keymap.set('i', '<C-e>', '<End>', { remap = false })
      vim.keymap.set('i', '<C-p>', '<Up>', { remap = false })
      vim.keymap.set('i', '<C-n>', '<Down>', { remap = false })
      vim.keymap.set('i', '<C-f>', '<right>', { remap = false })
      vim.keymap.set('i', '<C-b>', '<left>', { remap = false })

      -- Telescope設定
      require('telescope').setup{
        defaults = {
          mappings = { i = {["<F1>"] = "which_key"}}
        },
        pickers = {},
        extensions = {},
      }
      vim.keymap.set('n', [[<C-x>b]], [[<cmd>Telescope buffers<cr>]], {remap = false})
      vim.keymap.set('n', [[<C-x><C-f>]], [[<cmd>Telescope file_browser<cr>]], {remap = false})

      -- ToggleTerm設定
      require("toggleterm").setup {
        open_mapping = [[<c-t>]],
        direction = 'float',
      }
      vim.keymap.set('t', [[<ESC><ESC>]], [[<C-\><C-n>]], {remap = false})
    '';

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      telescope-nvim
      plenary-nvim
      telescope-file-browser-nvim
      toggleterm-nvim
    ];
  };
}
