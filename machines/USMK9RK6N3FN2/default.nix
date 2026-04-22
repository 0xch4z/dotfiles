{ pkgs, ... }: {
  ids.uids.nixbld = 300;

  users.users.ckenney = {
    name = "ckenney";
    home = "/Users/ckenney";
    shell = pkgs.fish;
  };

  nix.settings.trusted-users = ["ckenney"];

  services.nix-daemon.enable = true;
}
