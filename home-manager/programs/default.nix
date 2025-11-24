{ pkgs, lib, isWSL ? false, ... }:
{
  imports = [
    ./chezmoi
    ./claude-code
    ./cmake
    ./direnv
    ./emacs
    ./fd
    ./fzf
    ./gcc
    ./ghq
    ./git
    ./gitstatus
    ./glibtool
    ./gnumake
    ./libtool
    ./nixvim
    ./ripgrep
    ./tree
    ./unar
    ./vim
  ] ++ lib.optionals (!isWSL) [ ./wezterm ] ++ [
    ./zsh
  ];
}