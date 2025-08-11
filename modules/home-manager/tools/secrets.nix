{ self, config, pkgs, ... }:
let
  inherit (self.lib) mkEnableOption mkIf;

  cfg = config.x.home.tools.secrets;
in {
  options.x.home.tools.secrets = {
    enable = mkEnableOption "enable secrets tools";
  };

  config = mkIf cfg.enable {
    programs.rbw = {
      enable = true;
      settings = {
        email = "charlesc.kenney@gmail.com";
        lock_timeout = 3600 * 10;
        pinentry = with pkgs; (if pkgs.stdenv.hostPlatform.isDarwin then
          pinentry_mac
        else
          pinentry);
      };
    };

    home = {
      packages = with pkgs; [
        age
        pass
        sops
        (if pkgs.stdenv.hostPlatform.isDarwin then
          pinentry_mac
        else
          pinentry)
      ];

    };
  };
}
