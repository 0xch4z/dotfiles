{variant, userhost, ...}: {
  imports = [
    ./applications
    ./desktop
    ./development
    ./editor
    ./shell
    ./taskbar
    ./tools

    ./fonts.nix
    ./secrets.nix
    ./theme.nix
  ];

  home.sessionVariables = {
    NIX_SYSTEM = "1";
    NIX_VARIANT = variant;
    NIX_USERHOST = userhost;
  };
}
