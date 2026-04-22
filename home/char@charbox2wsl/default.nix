{ lib, ... }: {
  imports = [
    ../../profiles/nixos
  ];

  x.profile.workstation = true;
  x.profile.personal = true;

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/home/char";
}
