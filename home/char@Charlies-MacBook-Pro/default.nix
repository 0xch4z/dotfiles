{ config, lib, pkgs, user, darwin, inputs, ... }@args: {
  imports = [
    ../../roles/personal-macos
    ../../profiles/personal-macos
  ];

  home.stateVersion = "22.11";
}
