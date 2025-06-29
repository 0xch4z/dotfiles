{ self, config, pkgs, ... }:
let
  inherit (self.lib) mkEnableOption mkIf;

  cfg = config.x.home.tools.secrets;
in {
  options.x.home.tools.secrets = {
    enable = mkEnableOption "enable secrets tools";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        age
        pass
        rbw
        sops
        (if pkgs.stdenv.hostPlatform.isDarwin then
          pinentry_mac
        else
          pinentry)
      ];
    };
  };
}
