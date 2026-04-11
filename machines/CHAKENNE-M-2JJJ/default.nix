{ pkgs, ... }: {
  system.primaryUser = "chakenne";

  users.users.chakenne = {
    name = "chakenne";
    home = "/Users/chakenne";
    shell = pkgs.fish;
  };

  system.defaults.NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;

  nix = {
    enable = false;
    settings.trusted-users = [ "chakenne" ];
  };
}
