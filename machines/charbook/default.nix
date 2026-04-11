{  pkgs, ... }: {
  ids.uids.nixbld = 300;

  networking.hostName = "charbook";
  networking.computerName = "charbook";
  networking.localHostName = "charbook";

  system.primaryUser = "char";

  users.users.char = {
    name = "char";
    home = "/Users/char";
    shell = pkgs.fish;
  };

  system.defaults.dock.tilesize = 75;
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;

  services.openssh.enable = true;

  nix = {
    enable = false;
    settings.trusted-users = ["root" "char"];
  };
}
