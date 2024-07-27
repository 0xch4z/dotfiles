{config, pkgs, ...}: {
  imports = [
    ../common
  ];

  home = {
    packages = with pkgs; [
      git
    ];

    sessionVariables = {
      XDG_RUNTIME_DIR = "$TMPDIR";
    };

    shellAliases = {
    };
  };
}
