_: {
  den.aspects.tools-io.homeManager =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          dool
          hexdump
          htop
          iotop
          lsof
          pv
          unixtools.xxd
          #strace #broken?
          hwatch
          watch
          ttyd
        ];
      };
    };
}
