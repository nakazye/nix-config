{
  pkgs,
  lib,
  isWSL ? false,
  ...
}: {
  imports =
    [
      ./alt-tab
      ./chezmoi
      ./claude-code
      ./cmake
      ./copilot
      ./direnv
      ./discord
      ./doll
      ./emacs
      ./fd
      ./fzf
      ./gcc
      ./ghq
      ./git
      ./gitstatus
      ./glibtool
      ./gnumake
      ./google-chrome
      ./jetbrains
      ./jordanbaird-ice
      ./libtool
      ./nixvim
      ./orion
      ./raycast
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
