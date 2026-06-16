{
  pkgs,
  lib,
  inputs,
  systemType,
  ...
}: let
  isWSL = systemType == "wsl";
  isMac = systemType == "privateMac" || systemType == "businessMac";
  isLinux = !isMac;
in {
  programs.nixvim = {
    enable = true;
    nixpkgs.source = inputs.nixpkgs;

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
    colorscheme = "sanrio-night";
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "sanrio-night-nvim";
        src = pkgs.writeTextDir "colors/sanrio-night.lua" ''
          vim.cmd("hi clear")
          if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
          vim.g.colors_name = "sanrio-night"
          vim.opt.background = "dark"

          local c = {
            bg      = "#1b1118",
            bg_alt  = "#271a22",
            bg_hl   = "#3a2432",
            fg      = "#f9e9f2",
            fg_dim  = "#c8a4bc",
            gray    = "#8a7082",
            red     = "#f08080",
            orange  = "#efa42b",
            yellow  = "#efc128",
            lime    = "#bcd60a",
            green   = "#91dea9",
            cyan    = "#8bd0dd",
            blue    = "#72b8f0",
            purple  = "#cda1dc",
            pink    = "#e383a8",
            magenta = "#f06aaa",
          }

          local hl = vim.api.nvim_set_hl

          -- Base UI
          hl(0, "Normal",        { fg = c.fg,      bg = c.bg })
          hl(0, "NormalFloat",   { fg = c.fg,      bg = c.bg_alt })
          hl(0, "NormalNC",      { fg = c.fg_dim,  bg = c.bg_alt })
          hl(0, "Comment",       { fg = c.fg_dim,  italic = true })
          hl(0, "Cursor",        { fg = c.bg,      bg = c.pink })
          hl(0, "CursorLine",    { bg = c.bg_alt })
          hl(0, "CursorColumn",  { bg = c.bg_alt })
          hl(0, "CursorLineNr",  { fg = c.pink,    bg = c.bg_alt })
          hl(0, "LineNr",        { fg = c.gray })
          hl(0, "SignColumn",    { fg = c.gray,    bg = c.bg })
          hl(0, "ColorColumn",   { bg = c.bg_alt })
          hl(0, "VertSplit",     { fg = c.bg_hl,   bg = c.bg })
          hl(0, "WinSeparator",  { fg = c.bg_hl,   bg = c.bg })
          hl(0, "Folded",        { fg = c.gray,    bg = c.bg_alt })
          hl(0, "FoldColumn",    { fg = c.gray,    bg = c.bg })
          hl(0, "StatusLine",    { fg = c.fg,      bg = c.bg_hl })
          hl(0, "StatusLineNC",  { fg = c.gray,    bg = c.bg_alt })
          hl(0, "TabLine",       { fg = c.gray,    bg = c.bg_alt })
          hl(0, "TabLineSel",    { fg = c.fg,      bg = c.bg_hl })
          hl(0, "TabLineFill",   { bg = c.bg })
          hl(0, "Pmenu",         { fg = c.fg,      bg = c.bg_alt })
          hl(0, "PmenuSel",      { fg = c.fg,      bg = c.bg_hl })
          hl(0, "PmenuSbar",     { bg = c.bg_hl })
          hl(0, "PmenuThumb",    { bg = c.gray })
          hl(0, "Visual",        { bg = c.bg_hl })
          hl(0, "VisualNOS",     { bg = c.bg_hl })
          hl(0, "Search",        { fg = c.bg,      bg = c.yellow })
          hl(0, "IncSearch",     { fg = c.bg,      bg = c.orange })
          hl(0, "CurSearch",     { fg = c.bg,      bg = c.orange })
          hl(0, "ErrorMsg",      { fg = c.red })
          hl(0, "WarningMsg",    { fg = c.orange })
          hl(0, "ModeMsg",       { fg = c.green })
          hl(0, "MoreMsg",       { fg = c.green })
          hl(0, "Question",      { fg = c.cyan })
          hl(0, "Title",         { fg = c.magenta, bold = true })
          hl(0, "Directory",     { fg = c.cyan })
          hl(0, "MatchParen",    { fg = c.magenta, bold = true })
          hl(0, "NonText",       { fg = c.bg_hl })
          hl(0, "SpecialKey",    { fg = c.bg_hl })
          hl(0, "Whitespace",    { fg = c.bg_hl })
          hl(0, "EndOfBuffer",   { fg = c.bg_hl })
          hl(0, "WildMenu",      { fg = c.bg,      bg = c.pink })
          hl(0, "DiffAdd",       { fg = c.green,   bg = c.bg_alt })
          hl(0, "DiffChange",    { fg = c.yellow,  bg = c.bg_alt })
          hl(0, "DiffDelete",    { fg = c.red,     bg = c.bg_alt })
          hl(0, "DiffText",      { fg = c.orange,  bg = c.bg_hl })
          hl(0, "SpellBad",      { undercurl = true, sp = c.red })
          hl(0, "SpellCap",      { undercurl = true, sp = c.blue })
          hl(0, "SpellRare",     { undercurl = true, sp = c.purple })
          hl(0, "SpellLocal",    { undercurl = true, sp = c.cyan })

          -- Syntax
          hl(0, "Constant",      { fg = c.orange })
          hl(0, "String",        { fg = c.green })
          hl(0, "Character",     { fg = c.green })
          hl(0, "Number",        { fg = c.yellow })
          hl(0, "Boolean",       { fg = c.orange })
          hl(0, "Float",         { fg = c.yellow })
          hl(0, "Identifier",    { fg = c.fg })
          hl(0, "Function",      { fg = c.cyan })
          hl(0, "Statement",     { fg = c.purple })
          hl(0, "Conditional",   { fg = c.purple })
          hl(0, "Repeat",        { fg = c.purple })
          hl(0, "Label",         { fg = c.purple })
          hl(0, "Operator",      { fg = c.pink })
          hl(0, "Keyword",       { fg = c.purple })
          hl(0, "Exception",     { fg = c.red })
          hl(0, "PreProc",       { fg = c.lime })
          hl(0, "Include",       { fg = c.purple })
          hl(0, "Define",        { fg = c.lime })
          hl(0, "Macro",         { fg = c.lime })
          hl(0, "PreCondit",     { fg = c.lime })
          hl(0, "Type",          { fg = c.blue })
          hl(0, "StorageClass",  { fg = c.purple })
          hl(0, "Structure",     { fg = c.blue })
          hl(0, "Typedef",       { fg = c.blue })
          hl(0, "Special",       { fg = c.pink })
          hl(0, "SpecialChar",   { fg = c.orange })
          hl(0, "Tag",           { fg = c.pink })
          hl(0, "Delimiter",     { fg = c.fg_dim })
          hl(0, "SpecialComment",{ fg = c.gray,    italic = true })
          hl(0, "Debug",         { fg = c.orange })
          hl(0, "Underlined",    { underline = true })
          hl(0, "Ignore",        { fg = c.gray })
          hl(0, "Error",         { fg = c.red,     bold = true })
          hl(0, "Todo",          { fg = c.bg,      bg = c.yellow, bold = true })

          -- Treesitter
          hl(0, "@comment",              { link = "Comment" })
          hl(0, "@keyword",              { link = "Keyword" })
          hl(0, "@keyword.function",     { fg = c.purple })
          hl(0, "@keyword.return",       { fg = c.purple })
          hl(0, "@keyword.operator",     { fg = c.pink })
          hl(0, "@function",             { fg = c.cyan })
          hl(0, "@function.builtin",     { fg = c.magenta })
          hl(0, "@function.macro",       { fg = c.lime })
          hl(0, "@method",               { fg = c.cyan })
          hl(0, "@method.call",          { fg = c.cyan })
          hl(0, "@constructor",          { fg = c.blue })
          hl(0, "@parameter",            { fg = c.red })
          hl(0, "@variable",             { fg = c.fg })
          hl(0, "@variable.builtin",     { fg = c.orange })
          hl(0, "@field",                { fg = c.fg })
          hl(0, "@property",             { fg = c.fg })
          hl(0, "@string",               { link = "String" })
          hl(0, "@string.escape",        { fg = c.orange })
          hl(0, "@number",               { link = "Number" })
          hl(0, "@float",                { link = "Float" })
          hl(0, "@boolean",              { link = "Boolean" })
          hl(0, "@constant",             { link = "Constant" })
          hl(0, "@constant.builtin",     { fg = c.orange })
          hl(0, "@type",                 { link = "Type" })
          hl(0, "@type.builtin",         { fg = c.blue })
          hl(0, "@namespace",            { fg = c.blue })
          hl(0, "@operator",             { link = "Operator" })
          hl(0, "@punctuation",          { fg = c.fg_dim })
          hl(0, "@punctuation.delimiter",{ fg = c.fg_dim })
          hl(0, "@punctuation.bracket",  { fg = c.fg_dim })
          hl(0, "@punctuation.special",  { fg = c.pink })
          hl(0, "@tag",                  { fg = c.pink })
          hl(0, "@tag.attribute",        { fg = c.blue })
          hl(0, "@tag.delimiter",        { fg = c.fg_dim })
          hl(0, "@attribute",            { fg = c.lime })
          hl(0, "@label",                { fg = c.purple })

          -- Diagnostics
          hl(0, "DiagnosticError",            { fg = c.red })
          hl(0, "DiagnosticWarn",             { fg = c.orange })
          hl(0, "DiagnosticInfo",             { fg = c.cyan })
          hl(0, "DiagnosticHint",             { fg = c.green })
          hl(0, "DiagnosticUnderlineError",   { undercurl = true, sp = c.red })
          hl(0, "DiagnosticUnderlineWarn",    { undercurl = true, sp = c.orange })
          hl(0, "DiagnosticUnderlineInfo",    { undercurl = true, sp = c.cyan })
          hl(0, "DiagnosticUnderlineHint",    { undercurl = true, sp = c.green })

          -- Telescope
          hl(0, "TelescopeNormal",         { fg = c.fg,     bg = c.bg_alt })
          hl(0, "TelescopeBorder",         { fg = c.bg_hl,  bg = c.bg_alt })
          hl(0, "TelescopePromptNormal",   { fg = c.fg,     bg = c.bg_hl })
          hl(0, "TelescopePromptBorder",   { fg = c.bg_hl,  bg = c.bg_hl })
          hl(0, "TelescopePromptTitle",    { fg = c.bg,     bg = c.pink })
          hl(0, "TelescopePreviewTitle",   { fg = c.bg,     bg = c.cyan })
          hl(0, "TelescopeResultsTitle",   { fg = c.bg,     bg = c.purple })
          hl(0, "TelescopeSelectionCaret", { fg = c.pink })
          hl(0, "TelescopeSelection",      { fg = c.fg,     bg = c.bg_hl })
          hl(0, "TelescopeMatching",       { fg = c.yellow, bold = true })
        '';
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "telescope-ghq-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "nvim-telescope";
          repo = "telescope-ghq.nvim";
          rev = "master";
          hash = "sha256-bOpgGxaSUN/+3DCm2+8G57y+miPmeMIuDQaO4Ugikf4=";
        };
      })
    ];

    # telescope-ghq拡張のロード
    extraConfigLua = ''
      require('telescope').load_extension('ghq')
    '';

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
      })
      emacsInsertKeys;

    # プラグイン設定
    plugins = {
      # アイコン
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
        keymaps = {
          "<C-x>b" = "buffers";
          "<C-x><C-f>" = "find_files";
          "<leader>gr" = "ghq list";
        };
      };
    };
  };
}
