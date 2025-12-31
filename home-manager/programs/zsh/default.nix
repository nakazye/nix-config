{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.zsh = {
    enable = true;

    # auto_cd (ディレクトリ名だけでcd)
    autocd = true;

    # Emacsライクキーバインド
    defaultKeymap = "emacs";

    # シェルオプション
    initContent = ''
      # 標準エディタ（Emacsの軽量CLI起動）
      export EDITOR="emacs -nw -Q -l ~/.config/emacs/cli-minimal-init.el"

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


      # プロンプト指定
      PROMPT="
      [%n] %F{yellow}%~%f
      %(?.%F{green}.%F{blue})%(?!(*'-') <!(*;-;%)? <)%f "
      PROMPT2='[%n]> '

      # gitstatus初期化
      setopt prompt_subst
      source ${pkgs.gitstatus}/share/gitstatus/gitstatus.plugin.zsh

      # 既に起動していなければ起動（高速化オプション付き）
      # -s 1 = staged files を1つ見つけたら停止
      # -u 1 = unstaged files を1つ見つけたら停止
      # -d 1 = untracked files を1つ見つけたら停止
      gitstatus_check 'MY' 2>/dev/null || gitstatus_start -s 1 -u 1 -d 1 'MY'

      # Git情報をRPROMPTに表示する関数
      function my_git_prompt() {
        gitstatus_query 'MY' || return 1
        local branch="''${VCS_STATUS_LOCAL_BRANCH:-@''${VCS_STATUS_COMMIT[1,8]}}"

        # Git情報がない場合は表示しない
        [[ "$branch" == "@" ]] && return 0

        local git_status=""

        # 変更がある場合（コミット数もカウントしない）
        [[ $VCS_STATUS_HAS_STAGED    -ne 0 ]] && git_status+="%F{yellow}!%f"
        [[ $VCS_STATUS_HAS_UNSTAGED  -ne 0 ]] && git_status+="%F{red}+%f"
        [[ $VCS_STATUS_HAS_UNTRACKED -ne 0 ]] && git_status+="%F{blue}?%f"

        echo "%F{green}''${git_status}[''${branch}]%f"
      }

      RPROMPT=$RPROMPT'$(my_git_prompt)'

      # もしかして機能のプロンプト
      SPROMPT="%F{red}%{$suggest%}(*'~'%)? < %B%r%b %F{red}? [Yes!(y), No!(n),a,e]:%f "

      # 履歴検索のキーバインド
      autoload -U history-search-end
      zle -N history-beginning-search-backward-end history-search-end
      zle -N history-beginning-search-forward-end history-search-end
      bindkey "^P" history-beginning-search-backward-end
      bindkey "^N" history-beginning-search-forward-end
    '';

    # abbreviation設定（入力時に展開され、履歴にも展開後のコマンドが残る）
    zsh-abbr = {
      enable = true;
      abbreviations = lib.mkMerge [
        {
          # 共通abbreviation
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
      # 1日1回だけチェック（高速化）
      if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
        compinit -d ~/.zcompdump
      else
        compinit -C -d ~/.zcompdump
      fi

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
