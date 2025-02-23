{ lib, ... }@args: {
  imports = [
    ../../profiles/nixos
    ../../roles/nixos
  ];

  home.stateVersion = lib.mkForce "22.11";
  home.homeDirectory = "/home/char";
}
