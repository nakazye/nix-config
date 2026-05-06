{pkgs-unstable, ...}: {
  home.packages = [pkgs-unstable.claude-code];

  home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;

  home.file.".claude/settings.json".text = builtins.toJSON {
    enabledPlugins = {
      "clangd-lsp@claude-plugins-official" = true;
    };
    alwaysThinkingEnabled = true;
    prefersReducedMotion = true;
    permissions = {
      allow = [
        "Bash(iconv:*)"
      ];
    };
  };
}
