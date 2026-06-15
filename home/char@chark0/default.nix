{ ... }: {
  imports = [
    ../../profiles/nixos
  ];

  x.profile.personal = true;
  x.profile.workstation = true;

  x.home.desktop.enable = false;

  home.stateVersion = "24.11";
  home.homeDirectory = "/home/char";
}
