{
  self,
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (self.lib) mkEnabledOption;
  cfg = config.x.home.development.ai.opencode;
  mcpCfg = config.x.home.development.ai.mcpServers;
  permCfg = config.x.home.development.ai.permissions;
  ctxCfg = config.x.home.development.ai.context;
  lspCfg = config.x.home.development.lsp;
  opencodeV1 = pkgs.writeShellApplication {
    name = "opencode";
    text = ''
      exec ${lib.getExe cfg.v1Package} "$@"
    '';
  };

  lspServers = lib.mapAttrs' (
    _: srv:
    lib.nameValuePair srv.opencode (
      {
        command = [ srv.command ] ++ srv.args;
        inherit (srv) extensions;
      }
      // lib.optionalAttrs (srv.env != { }) { env = srv.env; }
      // lib.optionalAttrs (srv.initialization != { }) { initialization = srv.initialization; }
    )
  ) (lib.filterAttrs (_: srv: srv.opencode != null && srv.extensions != [ ]) lspCfg.resolved);
in
{
  options.x.home.development.ai.opencode = {
    enable = mkEnabledOption "enable opencode";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = self.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2;
      description = "opencode package to install. Set to null to manage the CLI outside Home Manager.";
    };

    v1Package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = self.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
      description = "OpenCode v1 package exposed as the opencode command.";
    };
  };

  config = lib.mkIf (config.x.home.development.enable && cfg.enable) {
    home.packages = lib.optional (cfg.v1Package != null) opencodeV1;

    programs.opencode = {
      enable = true;
      inherit (cfg) package;

      enableMcpIntegration = mcpCfg.enable;

      settings = {
        autoupdate = false;
        lsp = lspServers;
        shell = "${pkgs.fish}/bin/fish";

        permission = permCfg.rendered.opencode;
      };

      context = ctxCfg.rendered;
    };
  };
}
