{ inputs, den, ... }:
{
  den.hosts.aarch64-darwin.charbook.users.char = { };

  den.aspects.charbook = {
    includes = [ den.aspects.darwin-base ];

    darwin =
      { pkgs, ... }:
      {
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
          settings.trusted-users = [
            "root"
            "char"
          ];
        };
      };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [ inputs.mac-app-util.homeManagerModules.default ];
    home-manager.extraSpecialArgs = { inherit inputs; };
  };
}
