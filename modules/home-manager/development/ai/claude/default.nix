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

  notifyCmd = (
    if pkgs.stdenv.hostPlatform.isDarwin then
      ''test "$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')" != "Alacritty" && ${pkgs.terminal-notifier}/bin/terminal-notifier -message''
    else
      ''hyprctl activewindow -j | ${pkgs.jq}/bin/jq -e '.class != "Alacritty"' > /dev/null && hyprctl notify -1 3000 'rgb(ff1ea3)' ''
  );

  # language servers installed via nix, keyed by language name.
  # uses explicit nix store paths to avoid binary name mismatches
  # (e.g. lua-language-server vs lua-ls).
  lspServers = {
    go = {
      command = "${pkgs.gopls}/bin/gopls";
      args = [ "serve" ];
      extensionToLanguage = { ".go" = "go"; };
    };
    rust = {
      command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      args = [ ];
      extensionToLanguage = { ".rs" = "rust"; };
    };
    python = {
      command = "${pkgs.pyright}/bin/pyright-langserver";
      args = [ "--stdio" ];
      extensionToLanguage = { ".py" = "python"; };
    };
    typescript = {
      command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".ts" = "typescript";
        ".tsx" = "typescriptreact";
        ".js" = "javascript";
        ".jsx" = "javascriptreact";
      };
    };
    nix = {
      command = "${pkgs.nixd}/bin/nixd";
      args = [ ];
      extensionToLanguage = { ".nix" = "nix"; };
    };
    lua = {
      command = "${pkgs.lua-language-server}/bin/lua-language-server";
      args = [ ];
      extensionToLanguage = { ".lua" = "lua"; };
    };
    yaml = {
      command = "${pkgs.yaml-language-server}/bin/yaml-language-server";
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".yaml" = "yaml";
        ".yml" = "yaml";
      };
    };
    terraform = {
      command = "${pkgs.terraform-ls}/bin/terraform-ls";
      args = [ "serve" ];
      extensionToLanguage = {
        ".tf" = "terraform";
        ".tfvars" = "terraform";
      };
    };
    markdown = {
      command = "${pkgs.marksman}/bin/marksman";
      args = [ "server" ];
      extensionToLanguage = { ".md" = "markdown"; };
    };
    elixir = {
      command = "${pkgs.elixir-ls}/bin/elixir-ls";
      args = [ ];
      extensionToLanguage = {
        ".ex" = "elixir";
        ".exs" = "elixir";
      };
    };
    tailwindcss = {
      command = "${pkgs.nodePackages."@tailwindcss/language-server"}/bin/tailwindcss-language-server";
      args = [ "--stdio" ];
      extensionToLanguage = { ".css" = "tailwindcss"; };
    };
  };

  lspPlugin = pkgs.writeTextDir "plugin.json" (builtins.toJSON {
    name = "nix-managed-lsp";
    description = "Language servers installed and managed by nix home-manager";
    inherit lspServers;
  });

  # generate the LSP section of CLAUDE.md from lspServers
  lspList = lib.concatStringsSep "\n" (lib.mapAttrsToList (
    name: srv:
    let
      bin = builtins.baseNameOf srv.command;
      exts = lib.concatStringsSep ", " (lib.attrNames srv.extensionToLanguage);
    in
    "- **${name}**: `${bin}` (${exts})"
  ) lspServers);
in
{
  options.x.home.development.ai.claude = {
    enable = mkEnabledOption "enable claude code config";
    taskNotifications = mkEnabledOption "enable task notifications";
  };

  config = lib.mkIf cfg.enable {
    # place custom LSP plugin in ~/.claude/plugins/
    home.file.".claude/plugins/nix-managed-lsp" = {
      source = lspPlugin;
      recursive = true;
    };

    programs.claude-code = {
      enable = true;
      # don't install the cli; managed externally
      package = null;

      memory.text = ''
        # Language Servers

        This system uses nix home-manager to manage language servers. The following
        LSPs are installed and available — always prefer the LSP tool (go-to-definition,
        find-references, hover, diagnostics) over Grep/Glob for navigating code:

        ${lspList}

        ## Guidelines
        - Do NOT suggest installing language servers that are already available above.
        - For languages without an LSP installed, suggest the user install it via nix
          home-manager (permanent) or `nix-shell -p <pkg>` (temporary, instant).
        - Use LSP for: finding definitions, references, symbols, type info, and diagnostics.
        - Fall back to Grep/Glob only when LSP cannot answer the query (e.g. searching
          for string literals, comments, or across languages without an LSP).
      '';

      settings = {
        enabledPlugins = {
          "frontend-design@claude-plugins-official" = true;
          "nix-managed-lsp" = true;
        };

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
  };
}
