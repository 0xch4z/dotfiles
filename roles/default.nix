{ lib, ... }: {
  options.x.profile = {
    workstation = lib.mkEnableOption "workstation profile";
    personal = lib.mkEnableOption "personal profile";
    work = lib.mkEnableOption "work profile";
  };

  imports = [
    ./workstation.nix
    ./mac-workstation.nix
    ./nix-workstation.nix
    ./personal.nix
    ./work.nix
  ];
}
