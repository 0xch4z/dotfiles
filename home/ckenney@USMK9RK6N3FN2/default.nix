{ config, lib, pkgs, user, darwin, inputs, ... }@args: {
  imports = [
    ../../roles/work-macos
    ../../profiles/work-macos
  ];

  home.stateVersion = "22.11";
}
