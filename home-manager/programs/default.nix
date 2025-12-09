{
  pkgs,
  lib,
  systemType,
  ...
}: {
  imports =
    [
      ./alt-tab
      ./chawan
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
      ./homerow
      ./jetbrains
      ./jordanbaird-ice
      ./libtool
      ./nixvim
      ./notunes
      ./orion
      ./raycast
      ./ripgrep
      ./slack
      ./tree
      ./unar
      ./vim
      ./voiceink
    ]
    ++ lib.optionals (systemType != "wsl") [./wezterm]
    ++ [
      ./zsh
    ];
}
