{ user, ... }: {
  imports = [
    ../../profiles/work-macos
  ];

  x.profile.workstation = true;
  x.profile.work = true;

  home.stateVersion = "22.11";
  home.homeDirectory = "/Users/${user}";
}
