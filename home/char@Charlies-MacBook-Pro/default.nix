{ lib, user, ... }: {
  imports = [
    ../../profiles/personal-macos
  ];

  x.profile.workstation = true;
  x.profile.personal = true;

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/Users/${user}";
}
