{ den, ... }:
{
  den.aspects.tools = {
    includes = [
      den.aspects.containers
      den.aspects.infrastructure
      den.aspects.file
      den.aspects.tools-io
      den.aspects.tools-networking
      den.aspects.productivity
      den.aspects.tools-secrets
    ];

    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.x.home.tools;
      in
      {
        options.x.home.tools = {
          coreutils = lib.mkOption {
            type = lib.types.enum [
              "essential"
              "full"
              "none"
            ];
            default = "none";
          };
        };

        config = {
          home.packages = with pkgs; [
            (lib.mkIf (cfg.coreutils == "essential") coreutils)
            (lib.mkIf (cfg.coreutils == "full") coreutils-full)
          ];
        };
      };
  };
}
