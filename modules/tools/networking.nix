_: {
  den.aspects.tools-networking.homeManager =
    { pkgs, ... }:
    {
      home = {
        packages =
          with pkgs;
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
            rsync
            socat
            trippy
            wget
            wrk
          ]
          ++ (if pkgs.stdenv.hostPlatform.isDarwin then [ iproute2mac ] else [ ]);
      };
    };
}
