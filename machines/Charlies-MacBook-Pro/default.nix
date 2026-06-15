{ pkgs, ... }: {
  ids.uids.nixbld = 300;

  system.primaryUser = "char";

  users.users.char = {
    name = "char";
    home = "/Users/char";
    shell = pkgs.fish;
  };

  system.defaults.dock.tilesize = 75;

  nix.settings.trusted-users = [
    "root"
    "char"
  ];
}
