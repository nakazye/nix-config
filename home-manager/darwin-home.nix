{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "nakazye";
    homeDirectory = "/Users/nakazye";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    cmake
    glibtool
    unar
    chezmoi
    tree
    fd
    ripgrep
    ghq
    fzf
    emacs
    vim
    neovim
  ];

  programs.zsh = {
    enable = true;

    # auto_cd (ディレクトリ名だけでcd)
    autocd = true;

    # Emacsライクキーバインド
    defaultKeymap = "emacs";

    # シェルオプション
    initExtra = ''
      # ビープ音を鳴らさない
      setopt nolistbeep

      # もしかして機能
      setopt correct

      # 補完が詰めて表示される
      setopt list_packed

      # ディレクトリのスラッシュを削除しない
      setopt noautoremoveslash

      # 移動したディレクトリの記憶
      setopt auto_pushd

      # エイリアスの補完
      setopt complete_aliases

      # 色設定
      autoload -U colors; colors

      # プロンプト指定
      PROMPT="
      [%n] %{''${fg[yellow]}%}%~%{''${reset_color}%}
      %(?.%{$fg[green]%}.%{$fg[blue]%})%(?!(*'-') <!(*;-;%)? <)%{''${reset_color}%} "
      PROMPT2='[%n]> '

      # VCS情報の設定
      autoload -Uz vcs_info
      setopt prompt_subst
      zstyle ':vcs_info:git:*' check-for-changes true
      zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
      zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
      zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
      zstyle ':vcs_info:*' actionformats '[%b|%a]'
      precmd () { vcs_info }
      RPROMPT=$RPROMPT'$'{vcs_info_msg_0_}

      # もしかして機能のプロンプト
      SPROMPT="%{$fg[red]%}%{$suggest%}(*'~'%)? < %B%r%b %{$fg[red]%}? [Yes!(y), No!(n),a,e]:''${reset_color} "

      # 履歴検索のキーバインド
      autoload history-search-end
      zle -N history-beginning-search-backward-end history-search-end
      zle -N history-beginning-search-forward-end history-search-end
      bindkey "^P" history-beginning-search-backward-end
      bindkey "^N" history-beginning-search-forward-end
    '';

    # エイリアス
    shellAliases = {
      # Mac用
      ls = "ls -G";
      ll = "ls -lG";
      la = "ls -laG";
      #Linux用
      # alias ls="ls --color";
      # alias ll="ls -l --color";
      # alias la="ls -la --color";
      du = "du -h";
      df = "df -h";
      vi = "nvim";
      ec = "emacsclient -n";
      rep = "cd $(ghq list -p | fzf -e)";
    };

    # コマンド履歴設定
    history = {
      size = 10000;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      share = true;
    };

    # 補完設定
    enableCompletion = true;
    completionInit = ''
      autoload -U compinit
      compinit

      zstyle ':completion:*:default' menu select=2
      zstyle ':completion:*' verbose yes
      zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
      zstyle ':completion:*:messages' format '%F{YELLOW}%d'$DEFAULT
      zstyle ':completion:*:warnings' format '%F{RED}No matches for: %F{YELLOW}%d'$DEFAULT
      zstyle ':completion:*:descriptions' format '%F{YELLOW}completing %B%d%b'$DEFAULT
      zstyle ':completion:*:options' description 'yes'
      zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'$DEFAULT
      zstyle ':completion:*' group-name ""
      zstyle ':completion:*' list-separator '-->'
      zstyle ':completion:*:manuals' separate-sections true
    '';
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };


  programs.git = {
    extraConfig = {
      core = {
        autocrlf = false;
        filemode = false;
        editor = "nvim";
      };
      init = {
        defaultBranch = "master";
      };
      ghq = {
        root = "~/src";
      };
    };
  };


  programs.neovim.plugins = [
    pkgs.vimPlugins.nvim-treesitter
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
