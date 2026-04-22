{ lib, user, ... }: {
  imports = [
    ../../profiles/work-macos
  ];

  x.profile.workstation = true;
  x.profile.work = true;

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/Users/${user}";
}
