{
  variant,
  userhost,
  homeDir,
  ...
}:
{
  imports = [
    ./applications
    ./desktop
    ./development
    ./editor
    ./games
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

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 3d --keep 3";
    flake = "${homeDir}/.dotfiles";
  };
}
