{ pkgs, ... }:
{
  home.packages = with pkgs; [
    libtool
  ];
}