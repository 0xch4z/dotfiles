{ self, config, pkgs, ... }:
let
  inherit (self.lib) mkEnableOption mkIf;

  cfg = config.x.home.tools.networking;
in {
  options.x.home.tools.networking = {
    enable = mkEnableOption "enable networking tools";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        arping
        curl
        dig
        grpcurl
        netcat
        socat
      ];
    };
  };
}
