{pkgs-unstable, ...}: {
  home.packages = [pkgs-unstable.claude-code];

  home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;
}
