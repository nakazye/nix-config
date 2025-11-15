{ pkgs, lib, config, ... }:
{
  programs.zsh = {
    enable = true;

    # auto_cd (ディレクトリ名だけでcd)
    autocd = true;

    # Emacsライクキーバインド
    defaultKeymap = "emacs";

    # シェルオプション
    initContent = ''
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

      # プロンプト指定
      PROMPT="
      [%n] %F{yellow}%~%f
      %(?.%F{green}.%F{blue})%(?!(*'-') <!(*;-;%)? <)%f "
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
      SPROMPT="%F{red}%{$suggest%}(*'~'%)? < %B%r%b %F{red}? [Yes!(y), No!(n),a,e]:%f "

      # 履歴検索のキーバインド
      autoload -U history-search-end
      zle -N history-beginning-search-backward-end history-search-end
      zle -N history-beginning-search-forward-end history-search-end
      bindkey "^P" history-beginning-search-backward-end
      bindkey "^N" history-beginning-search-forward-end
    '';

    # エイリアス
    shellAliases = lib.mkMerge [
      {
        # 共通エイリアス
        du = "du -h";
        df = "df -h";
        vi = "nvim";
        ec = "emacsclient -n";
        rep = "cd $(ghq list -p | fzf -e)";
      }
      (lib.mkIf pkgs.stdenv.isDarwin {
        # macOS用
        ls = "ls -G";
        ll = "ls -lG";
        la = "ls -laG";
      })
      (lib.mkIf pkgs.stdenv.isLinux {
        # Linux用
        ls = "ls --color";
        ll = "ls -l --color";
        la = "ls -la --color";
      })
    ];

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
      compinit -d ~/.zcompdump

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
}