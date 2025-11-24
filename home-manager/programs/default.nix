{ pkgs, lib, isWSL ? false, ... }:
{
  imports = [
    ./chezmoi
    ./claude-code
    ./direnv
    ./emacs
    ./fd
    ./fzf
    ./ghq
    ./git
    ./gitstatus
    ./nixvim
    ./ripgrep
    ./tree
    ./unar
    ./vim
  ] ++ lib.optionals (!isWSL) [ ./wezterm ] ++ [
    ./zsh
  ];
}