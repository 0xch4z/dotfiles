{ self, config, pkgs, ... }:
let
  inherit (self.lib) mkEnableOption mkIf;

  cfg = config.x.home.tools.containers.colima;
in {
  options.x.home.tools.containers.colima = {
    enable = mkEnableOption "enable colima";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        colima
      ];

      sessionVariables = {
        LIMA_HOME = "${config.xdg.configHome}/lima";
        DOCKER_HOST = "unix://$HOME/.colima/default/docker.sock";
      };
    };
  };
}
