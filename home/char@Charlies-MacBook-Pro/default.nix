{ lib, user, ... }@args: {
  imports = [
    ../../roles/personal-macos
    ../../profiles/personal-macos
  ];

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/Users/${user}";
}
