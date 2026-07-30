{
  self,
  config,
  pkgs,
  ...
}:
let
  inherit (self.lib) mkEnableOption mkIf;

  cfg = config.x.home.tools.io;
in
{
  options.x.home.tools.io = {
    enable = mkEnableOption "enable i/o tools";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        dool
        gettext
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
