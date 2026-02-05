{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.x.home.development.enable {
    home.sessionVariables.CODEX_HOME = "${config.xdg.configHome}/codex";

    xdg.configFile."codex/AGENTS.md".source = ./instructions/AGENTS.md;

    programs.codex = {
      enable = true;
      package = pkgs.unstable.codex;

      settings = {
        features = {
          shell_snapshot = true;
          web_search_request = true;
          tui2 = true;
        };

        experimental_instructions_file = "${config.xdg.configHome}/codex/AGENTS.md";

        approval_policy = "on-request";
        sandbox_mode = "workspace-write";

        sandbox_workspace_write = {
          network_access = true;
          exclude_tmpdir_env_var = false;
          exclude_slash_tmp = false;
        };
      };
    };
  };
}
