{ pkgs, lib, ... }:
{
  imports = [
    ./zsh
    ./unar
    ./chezmoi
    ./tree
    ./fd
    ./ripgrep
    ./ghq
    ./fzf
    ./emacs
    ./vim
    ./neovim
    ./git
    ./claude-code
  ];
}