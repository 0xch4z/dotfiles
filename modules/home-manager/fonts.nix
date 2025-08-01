{ self, config, pkgs, ... }:
let
  inherit (self.lib) mkEnableOption mkIf;

  cfg = config.x.home.fonts;
in {
  options.x.home.fonts = {
    apple-nerdfont.enable = mkEnableOption "enable apple-nerdfont";
  };

  config = {
    home = {
      packages = with pkgs; [
        (mkIf cfg.apple-nerdfont.enable x.apple-nerdfont)
      ];
    };
  };
}
