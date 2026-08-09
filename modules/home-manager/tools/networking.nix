{
  self,
  config,
  pkgs,
  ...
}:
let
  inherit (self.lib) mkEnableOption mkIf;

  cfg = config.x.home.tools.networking;
in
{
  options.x.home.tools.networking = {
    enable = mkEnableOption "enable networking tools";
  };

  config = mkIf cfg.enable {
    home = {
      packages =
        with pkgs;
        [
          arping
          bandwhich
          (lib.lowPrio bind)
          bmon
          curl
          curl-impersonate
          curlie
          dig
          gping
          grpcurl
          iperf3
          iftop
          (lib.lowPrio inetutils)
          lsof
          mtr
          netcat
          nghttp2
          openssl
          rsync
          socat
          trippy
          tcpdump
          wget
          wireshark-cli
          wrk
        ]
        ++ (if pkgs.stdenv.hostPlatform.isDarwin then [ iproute2mac ] else [ ])
        ++ (
          if pkgs.stdenv.hostPlatform.isLinux then
            [
              strace
              traceroute
            ]
          else
            [ ]
        );
    };
  };
}
