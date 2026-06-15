{ pkgs, ... }: {
  ids.uids.nixbld = 300;

  system.primaryUser = "ckenney";

  users.users.ckenney = {
    name = "ckenney";
    home = "/Users/ckenney";
    shell = pkgs.fish;
  };

  nix.settings.trusted-users = [ "ckenney" ];
}
