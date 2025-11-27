{
  pkgs,
  lib,
  isWSL ? false,
  ...
}: {
  imports =
    [
      ./chezmoi
      ./claude-code
      ./cmake
      ./direnv
      ./discord
      ./emacs
      ./fd
      ./fzf
      ./gcc
      ./ghq
      ./git
      ./gitstatus
      ./glibtool
      ./gnumake
      ./jetbrains
      ./libtool
      ./nixvim
      ./ripgrep
      ./slack
      ./tree
      ./unar
      ./vim
    ]
    ++ lib.optionals (!isWSL) [./wezterm]
    ++ [
      ./zsh
    ];
}
