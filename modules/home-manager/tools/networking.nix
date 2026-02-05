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
      packages = with pkgs;
        [
          arping
          bmon
          curl
          dig
          gping
          grpcurl
          iperf3
          mtr
          netcat
          nghttp2
          socat
          trippy
          wrk
        ]
        ++ (if pkgs.stdenv.hostPlatform.isDarwin then [ iproute2mac ] else [ ]);
    };
  };
}
