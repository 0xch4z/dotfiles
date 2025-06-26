{lib, ...}: {
  imports = [
    ./workstation.nix
  ];

  x.home.tools.containers.colima.enable = true;
}
