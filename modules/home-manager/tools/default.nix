{ self, config, pkgs, ... }:
let
  inherit (self.lib) mkIf mkOption mkEnableOption;

  cfg = config.x.home.tools;
in {
  options.x.home.tools = {
    coreutils = mkOption {
      type = self.lib.types.enum ["essential" "full" "none"];
      default = "none";
    };
  };

  imports = [
    ./containers
    ./file.nix
    ./infrastructure
    ./io.nix
    ./networking.nix
    ./productivity.nix
    ./secrets.nix
  ];

  config = {
    home.packages = with pkgs; [
      (mkIf (cfg.coreutils == "essential") coreutils)
      (mkIf (cfg.coreutils == "full") coreutils-full)
    ];
  };
}
