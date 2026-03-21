{
  pkgs,
  lib,
  systemType,
  ...
}: {
  programs.git = {
    enable = true;
    settings = {
      core =
        {
          autocrlf = false;
          filemode = false;
          editor = "nvim";
        }
        // lib.optionalAttrs (systemType == "wsl") {
          sshCommand = "/mnt/c/Windows/System32/OpenSSH/ssh.exe";
        };
      user = {
        useConfigOnly = true;
      };
      init = {
        defaultBranch = "master";
      };
      ghq = {
        root = "~/src";
      };
    };
  };
}
