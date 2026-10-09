{
  pkgs,
  self,
  config,
  lib,
  ...
}:
let
  inherit (self.lib) mkEnabledOption;
  cfg = config.x.home.development.ai.claude;
  mcpCfg = config.x.home.development.ai.mcpServers;
  permCfg = config.x.home.development.ai.permissions;
  ctxCfg = config.x.home.development.ai.context;

  notifyCmd = (
    if pkgs.stdenv.hostPlatform.isDarwin then
      ''test "$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')" != "Alacritty" && ${pkgs.terminal-notifier}/bin/terminal-notifier -message''
    else
      ''hyprctl activewindow -j | ${pkgs.jq}/bin/jq -e '.class != "Alacritty"' > /dev/null && hyprctl notify -1 3000 'rgb(ff1ea3)' ''
  );

  # language servers come from the shared registry in development/lsp.nix, which
  # each language module contributes to when it is enabled. commands are absolute
  # store paths (an lspmux shim when multiplexing is on), so binary name
  # mismatches (lua-language-server vs lua-ls) never matter here.
  registered = lib.filterAttrs (
    _: srv: srv.extensionToLanguage != { }
  ) config.x.home.development.lsp.resolved;

  lspServers = lib.mapAttrs (
    _: srv:
    {
      inherit (srv) command args extensionToLanguage;
    }
    // lib.optionalAttrs (srv.env != { }) { inherit (srv) env; }
    // lib.optionalAttrs (srv.initialization != { }) { initializationOptions = srv.initialization; }
  ) registered;

  lspPlugin = pkgs.writeTextDir ".claude-plugin/plugin.json" (
    builtins.toJSON {
      name = "nix-managed-lsp";
      description = "Language servers installed and managed by nix home-manager";
      inherit lspServers;
    }
  );
in
{
  options.x.home.development.ai.claude = {
    enable = mkEnabledOption "enable claude code config";
    taskNotifications = mkEnabledOption "enable task notifications";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = self.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
    };

    mcpServers = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      description = "MCP servers merged into ~/.claude.json on activation.";
      default = lib.optionalAttrs mcpCfg.enable mcpCfg.servers;
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".claude/skills/nix-managed-lsp" = {
      source = lspPlugin;
      recursive = true;
    };

    programs.claude-code = {
      enable = true;
      inherit (cfg) package;

      context = ctxCfg.rendered;

      settings = {
        defaultMode = "acceptEdits";

        enabledPlugins = {
          "frontend-design@claude-plugins-official" = true;
          "nix-managed-lsp@skills-dir" = true;
          "rust-analyzer-lsp@claude-plugins-official" = false;
          "gopls-lsp@claude-plugins-official" = false;
        };

        permissions = permCfg.rendered.claude;

        hooks = {
          Stop = [
            {
              hooks = lib.mkIf cfg.taskNotifications [
                {
                  type = "command";
                  command = "${notifyCmd} 'Claude task has completed'";
                }
              ];
            }
          ];
        };
      };
    };

    home.activation = lib.mkIf (cfg.mcpServers != { }) {
      claudeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        servers=${lib.escapeShellArg (builtins.toJSON cfg.mcpServers)}
        claude_json="$HOME/.claude.json"
        if [ -f "$claude_json" ]; then
          tmp=$(${pkgs.coreutils}/bin/mktemp)
          ${pkgs.jq}/bin/jq --argjson servers "$servers" '.mcpServers = $servers' "$claude_json" > "$tmp"
          mv "$tmp" "$claude_json"
        else
          ${pkgs.jq}/bin/jq -n --argjson servers "$servers" '{mcpServers: $servers}' > "$claude_json"
        fi
        chmod 600 "$claude_json"
      '';
    };
  };
}
