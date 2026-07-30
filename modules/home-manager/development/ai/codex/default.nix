{
  self,
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (self.lib) mkEnabledOption;
  cfg = config.x.home.development.ai.codex;
  mcpCfg = config.x.home.development.ai.mcpServers;
  tomlFormat = pkgs.formats.toml { };
  codexSettings = {
    features = {
      shell_snapshot = true;
      tui2 = true;
      web_search_request = true;
    };

    approval_policy = "on-request";
    sandbox_mode = "workspace-write";

    sandbox_workspace_write = {
      network_access = true;
      exclude_tmpdir_env_var = false;
      exclude_slash_tmp = false;
    };

    shell_environment_policy = {
      "inherit" = "all";
    };

    projects = {
      "${config.home.homeDirectory}".trust_level = "trusted";
      "${config.home.homeDirectory}/.dotfiles".trust_level = "trusted";
      "${config.home.homeDirectory}/work".trust_level = "trusted";
    };
  } // lib.optionalAttrs mcpCfg.enable {
    mcp_servers = mcpCfg.servers;
  };
in
{
  options.x.home.development.ai.codex = {
    enable = mkEnabledOption "enable Codex";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = self.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
      description = "Codex CLI package to install. Set to null to manage the CLI outside Home Manager.";
    };
  };

  config = lib.mkIf (config.x.home.development.enable && cfg.enable) {
    home = {
      sessionVariables.CODEX_HOME = "${config.xdg.configHome}/codex";
    };

    programs.codex = lib.mkIf (cfg.package != null) {
      enable = true;
      package = cfg.package;
    };

    xdg.configFile."codex/config.toml" = {
      source = tomlFormat.generate "codex-config.toml" codexSettings;
      force = true;
    };
  };
}
