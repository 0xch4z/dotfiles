{ ... }: {
  imports = [
    ../../profiles/nixos
  ];

  x.profile.workstation = true;
  x.profile.personal = true;

  home.stateVersion = "22.11";
  home.homeDirectory = "/home/char";
}
