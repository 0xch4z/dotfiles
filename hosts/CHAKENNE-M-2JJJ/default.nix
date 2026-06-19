{ inputs, den, ... }:
{
  den.hosts.aarch64-darwin."CHAKENNE-M-2JJJ".users.chakenne = { };

  den.aspects."CHAKENNE-M-2JJJ" = {
    includes = [ den.aspects.darwin-base ];

    darwin =
      { pkgs, ... }:
      {
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
      };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [ inputs.mac-app-util.homeManagerModules.default ];
    home-manager.extraSpecialArgs = { inherit inputs; };
  };
}
