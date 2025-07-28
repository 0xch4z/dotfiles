{ self, config, pkgs, ... }:
let
  inherit (self.lib) mkEnableOption mkIf;

  cfg = config.x.home.tools.productivity;
in {
  options.x.home.tools.productivity = {
    enable = mkEnableOption "enable productivity tools";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        gum
        jira-cli-go
      ];
      sessionVariables = {
        #JIRA_AUTH_TYPE = "bearer";
      };
    };
  };
}
