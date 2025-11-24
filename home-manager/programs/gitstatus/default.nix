{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gitstatus
  ];
}
