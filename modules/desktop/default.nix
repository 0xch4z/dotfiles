{ ... }:
{
  den.aspects.desktop.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib)
        mkOption
        types
        ;
    in
    {
      options.x.home.desktop = {
        backend = mkOption {
          type = types.enum [
            "hyprland"
            "aerospace"
            "none"
          ];
          default = "none";
        };
      };

      config = {
        home.packages = with pkgs; [
          xdg-utils
        ];
      };
    };
}
