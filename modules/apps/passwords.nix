_: {
  den.aspects._1pass.homeManager =
    { pkgs, ... }:
    {
      config = {
        home.packages = [
          pkgs._1password-gui
        ];
      };
    };

  den.aspects.bitwarden.homeManager =
    { pkgs, ... }:
    {
      config = {
        home.packages = [
          # built on electron 39.8.10 (insecure)
          #pkgs.unstable.bitwarden-desktop
        ];
      };
    };
}
