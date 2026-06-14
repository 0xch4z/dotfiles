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
      extensionToLanguage = {
        ".go" = "go";
      };
    };
    rust = {
      command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      args = [ ];
      extensionToLanguage = {
        ".rs" = "rust";
      };
    };
    python = {
      command = "${pkgs.pyright}/bin/pyright-langserver";
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".py" = "python";
      };
    };
    typescript = {
      command = "${pkgs.typescript-language-server}/bin/typescript-language-server";
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
      extensionToLanguage = {
        ".nix" = "nix";
      };
    };
    lua = {
      command = "${pkgs.lua-language-server}/bin/lua-language-server";
      args = [ ];
      extensionToLanguage = {
        ".lua" = "lua";
      };
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
      extensionToLanguage = {
        ".md" = "markdown";
      };
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
      command = "${pkgs.tailwindcss-language-server}/bin/tailwindcss-language-server";
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".css" = "tailwindcss";
      };
    };
  };

  lspPlugin = pkgs.writeTextDir ".claude-plugin/plugin.json" (
    builtins.toJSON {
      name = "nix-managed-lsp";
      description = "Language servers installed and managed by nix home-manager";
      inherit lspServers;
    }
  );

  # one mcp-language-server instance per installed LSP, reusing the nix store
  # paths from lspServers so we don't install anything new. workspace is
  # resolved from $PWD at launch time (claude code expands ${VAR} refs).
  lspMcpServers = lib.mapAttrs' (name: srv: {
    name = "lsp-${name}";
    value = {
      type = "stdio";
      command = "${pkgs.unstable.mcp-language-server}/bin/mcp-language-server";
      args = [
        "-workspace"
        "\${PWD}"
        "-lsp"
        srv.command
      ]
      ++ lib.optionals (srv.args != [ ]) ([ "--" ] ++ srv.args);
    };
  }) lspServers;

  # generate the LSP section of CLAUDE.md from lspServers
  lspList = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: srv:
      let
        bin = builtins.baseNameOf srv.command;
        exts = lib.concatStringsSep ", " (lib.attrNames srv.extensionToLanguage);
      in
      "- **${name}**: `${bin}` (${exts})"
    ) lspServers
  );
in
{
  options.x.home.development.ai.claude = {
    enable = mkEnabledOption "enable claude code config";
    taskNotifications = mkEnabledOption "enable task notifications";

    # mcpServers go in ~/.claude.json rather than settings.json because the
    # claude cli doesn't read mcpServers from settings.json, and the
    # home-manager `mcpServers` option requires a non-null package (we manage
    # the cli externally). on activation, jq replaces the mcpServers key in
    # ~/.claude.json while preserving the rest of the cli's state.
    mcpServers = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      description = "MCP servers merged into ~/.claude.json on activation.";
      default = {
        filesystem = {
          type = "stdio";
          command = "${pkgs.nodejs}/bin/npx";
          args = [
            "-y"
            "@modelcontextprotocol/server-filesystem"
            "${config.home.homeDirectory}/work"
            "${config.home.homeDirectory}/.dotfiles"
            "${config.home.homeDirectory}/tmp"
          ];
        };
        context7 = {
          type = "http";
          url = "https://mcp.context7.com/mcp";
        };
      }
      // lspMcpServers;
    };
  };

  config = lib.mkIf cfg.enable {
    # place custom LSP plugin with explicit nix store paths
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
        defaultMode = "acceptEdits";

        enabledPlugins = {
          "frontend-design@claude-plugins-official" = true;
          "nix-managed-lsp" = true;
        };

        permissions = {
          allow = [
            "Edit"
            "Write"
            "MultiEdit"
            "Read"

            "Bash(gh pr list:*)"
            "Bash(gh pr view:*)"
            "Bash(gh pr diff:*)"
            "Bash(gh pr status:*)"
            "Bash(gh pr checks:*)"
            "Bash(gh issue list:*)"
            "Bash(gh issue view:*)"
            "Bash(gh issue status:*)"
            "Bash(gh run list:*)"
            "Bash(gh run view:*)"
            "Bash(gh run watch:*)"
            "Bash(gh workflow list:*)"
            "Bash(gh workflow view:*)"
            "Bash(gh release list:*)"
            "Bash(gh release view:*)"
            "Bash(gh repo view:*)"
            "Bash(gh repo list:*)"
            "Bash(gh search:*)"
            "Bash(gh browse:*)"
            "Bash(gh auth status)"

            "Bash(git status:*)"
            "Bash(git diff:*)"
            "Bash(git log:*)"
            "Bash(git show:*)"
            "Bash(git branch:*)"
            "Bash(git blame:*)"
            "Bash(git fetch:*)"
            "Bash(git remote -v)"
            "Bash(git stash list:*)"

            "Bash(go build:*)"
            "Bash(go test:*)"
            "Bash(go vet:*)"
            "Bash(go mod:*)"
            "Bash(gofmt:*)"
            "Bash(cargo check:*)"
            "Bash(cargo build:*)"
            "Bash(cargo test:*)"
            "Bash(cargo clippy:*)"

            "Bash(ls:*)"
            "Bash(rg:*)"
            "Bash(fd:*)"
            "Bash(jq:*)"
            "Bash(yq:*)"
            "Bash(cat:*)"
            "Bash(head:*)"
            "Bash(tail:*)"
            "Bash(wc:*)"
            "Bash(file:*)"
            "Bash(which:*)"
            "Bash(pwd)"
            "Bash(env)"

            "Bash(kubectl get:*)"
            "Bash(kubectl describe:*)"
            "Bash(kubectl logs:*)"
            "Bash(kubectl explain:*)"
            "Bash(kubectl top:*)"
            "Bash(kubectl config get-contexts:*)"
            "Bash(kubectl config current-context)"
            "Bash(cilium status:*)"
            "Bash(cilium version:*)"
          ];
          deny = [
            "Bash(gh api * -X POST*)"
            "Bash(gh api * -X DELETE*)"
            "Bash(gh api * --method POST*)"
            "Bash(gh api * --method DELETE*)"
            "Read(./.env)"
            "Read(./.env.*)"
            "Read(./**/secrets/**)"
            "Bash(rm -rf /*)"
            "Bash(sudo:*)"
          ];
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
