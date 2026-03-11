{
  self,
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (self.lib) mkEnableOption mkIntOption;

  cfg = config.x.home.tools.agentgateway;

  gwConfig = {
    type = "static";
    admin = {
      host = "0.0.0.0";
      port = cfg.service.port;
    };
  };
in
{
  options.x.home.tools.agentgateway = {
    enable = mkEnableOption "Enable agentgateway";

    service = {
      port = mkIntOption "agent gateway port" 9999;
      enable = mkEnableOption "enable agentgateway service";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.x.agentgateway ];

    systemd.user.services.agentgateway =
      lib.mkIf (cfg.service.enable && pkgs.stdenv.hostPlatform.isLinux)
        {
          Unit = {
            Description = "agentgateway Service";
            After = [ "network.target" ];
          };
          Service = {
            ExecStart =
              "${pkgs.x.agentgateway}/bin/agentgateway"
              + lib.optionalString (cfg.configFile != null) " -f ${cfg.configFile}";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };

    launchd.agents.agentgateway = lib.mkIf (cfg.service.enable && pkgs.stdenv.hostPlatform.isDarwin) {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.x.agentgateway}/bin/agentgateway"
        ]
        ++ lib.optionals (cfg.configFile != null) [
          "-f"
          (toString cfg.configFile)
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/agentgateway/stdout.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/agentgateway/stderr.log";
      };
    };
  };
}
