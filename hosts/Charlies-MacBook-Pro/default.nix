{ inputs, den, ... }:
{
  den.hosts.aarch64-darwin.Charlies-MacBook-Pro.users.char = { };

  den.aspects.Charlies-MacBook-Pro = {
    includes = [ den.aspects.darwin-base ];

    darwin =
      { pkgs, ... }:
      {
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
      };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [ inputs.mac-app-util.homeManagerModules.default ];
    home-manager.extraSpecialArgs = { inherit inputs; };
  };
}
