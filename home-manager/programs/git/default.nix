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
          ignorecase = false;
          quotepath = false;
          safecrlf = true;
        }
        // lib.optionalAttrs (systemType == "wsl") {
          sshCommand = "/mnt/c/Windows/System32/OpenSSH/ssh.exe";
        };
      push = {
        default = "simple";
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
