{config, pkgs, ...}: {
  imports = [
    ../../pkgs/container/colima
    #../../pkgs/desktop/window-manager/aerospace
    ../common
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
