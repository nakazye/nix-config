{
  pkgs,
  lib,
  isWSL ? false,
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
        // lib.optionalAttrs isWSL {
          sshCommand = "/mnt/c/Windows/System32/OpenSSH/ssh.exe";
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
