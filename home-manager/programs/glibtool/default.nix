{ pkgs, ... }:
{
  home.packages = with pkgs; [
    glibtool
  ];
}