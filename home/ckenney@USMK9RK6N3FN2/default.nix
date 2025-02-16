{ lib, user, ... }@args: {
  imports = [
    ../../roles/work-macos
    ../../profiles/work-macos
  ];

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/Users/${user}";
}
