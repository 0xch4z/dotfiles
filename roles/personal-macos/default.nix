{pkgs, ...}: {
  imports = [
    ../../pkgs/container/colima
    ../common
    ../macos
  ];

  home = {

    packages = with pkgs; [
    ];

    sessionVariables = {
      XDG_RUNTIME_DIR = "$TMPDIR";
    };

    shellAliases = {
    };
  };
}
