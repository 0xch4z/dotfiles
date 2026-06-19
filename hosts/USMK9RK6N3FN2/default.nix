{ inputs, den, ... }:
{
  den.hosts.aarch64-darwin."USMK9RK6N3FN2".users.ckenney = { };

  den.aspects."USMK9RK6N3FN2" = {
    includes = [ den.aspects.darwin-base ];

    darwin =
      { pkgs, ... }:
      {
        ids.uids.nixbld = 300;

        system.primaryUser = "ckenney";

        users.users.ckenney = {
          name = "ckenney";
          home = "/Users/ckenney";
          shell = pkgs.fish;
        };

        nix.settings.trusted-users = [ "ckenney" ];
      };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [ inputs.mac-app-util.homeManagerModules.default ];
    home-manager.extraSpecialArgs = { inherit inputs; };
  };
}
