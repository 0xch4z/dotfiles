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
  lspCfg = config.x.home.development.lsp;

  # opencode rejects a server id it doesn't know unless the entry carries an
  # `extensions` list, so every entry below gets one from the registry's
  # extensionToLanguage keys. Servers with no extensions declared can't be
  # routed to and are dropped.
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
  };

  config = lib.mkIf (config.x.home.development.enable && cfg.enable) {
    programs.opencode = {
      enable = true;
      inherit (cfg) package;

      enableMcpIntegration = mcpCfg.enable;

      settings = {
        lsp = lspServers;

        permissions = [
          {
            action = "shell";
            resource = "*";
            effect = "ask";
          }
          {
            action = "shell";
            resource = "gh auth status *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "gh issue list *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "gh issue view *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "gh pr checks *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "gh pr diff *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "gh pr list *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "gh pr view *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "gh repo view *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "gh run list *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "gh run view *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "gh search *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "gh api --method GET *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "gh api -X GET *";
            effect = "allow";
          }
          {
            action = "webfetch";
            resource = "*";
            effect = "allow";
          }
          {
            action = "websearch";
            resource = "*";
            effect = "allow";
          }
          {
            action = "edit";
            resource = "*";
            effect = "allow";
          }
        ];
      };

      context = ''
        # Language Servers

        Language servers are installed and configured by nix home-manager and
        multiplexed through lspmux. This configuration does not guarantee that the
        active OpenCode agent exposes an `lsp` tool.

        - Do NOT suggest installing language servers that are already configured.
        - Check the active tool catalog before navigating code. If an `lsp` tool is
          exposed, prefer it for go-to-definition, find-references, hover, and
          diagnostics.
        - If no `lsp` tool is exposed, state that the server is configured but the
          current agent cannot access it, then fall back to grep/glob. Do not imply
          that the language server is missing or unconfigured.
        - For languages without an LSP configured, suggest installing it via nix
          home-manager (permanent) or `nix-shell -p <pkg>` (temporary, instant).
        - Even when `lsp` is available, use grep/glob for string literals, comments,
          or queries that LSP cannot answer.
      '';
    };
  };
}
