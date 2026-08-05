{
  self,
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (self.lib) mkEnabledOption;
  cfg = config.x.home.development.lsp;

  address = [
    "127.0.0.1"
    27631
  ];

  serverType = lib.types.submodule (
    { name, config, ... }:
    {
      options = {
        package = lib.mkOption {
          type = lib.types.package;
          description = "Package providing the language server binary.";
        };

        exe = lib.mkOption {
          type = lib.types.str;
          default = builtins.baseNameOf (lib.getExe config.package);
          defaultText = lib.literalExpression "baseNameOf (lib.getExe package)";
          description = "Binary name inside `package`, also the name looked up on $PATH.";
        };

        args = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Arguments appended to the server command.";
        };

        extensionToLanguage = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          example = {
            ".rs" = "rust";
          };
          description = ''
            File extension to LSP languageId map. Claude Code routes a file to this
            server only when its extension is a key here; opencode consumes the keys
            as its `extensions` list.
          '';
        };

        opencode = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = name;
          description = ''
            opencode's server id. Use one of opencode's built-in ids (`rust`,
            `typescript`, `gopls`, `nixd`, ...) to override the built-in rather
            than registering a second server for the same language. Null opts out.
          '';
        };

        initialization = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "Initialization options sent with the LSP `initialize` request.";
        };

        env = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "Extra environment variables for the server process.";
        };

        multiplex = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Route this server through lspmux when lspmux is enabled.";
        };
      };
    }
  );

  # Turn a server into a drop-in replacement for itself: a shim that runs the
  # real binary under `lspmux client` so every agent and editor asking for the
  # same server in the same project shares one process.
  #
  # The shim resolves the server on $PATH at runtime instead of hardcoding one
  # store path, so a repo whose devshell pins its own rust-analyzer gets that
  # binary — still multiplexed — rather than ours. `*-lspmux` hits are skipped so
  # a shim left on $PATH by another generation can't make us exec ourselves.
  mkShim =
    srv:
    let
      fallback = "${srv.package}/bin/${srv.exe}";
    in
    pkgs.writeShellScript "${srv.exe}-lspmux" ''
      set -u

      self=$(${pkgs.coreutils}/bin/realpath "$0" 2>/dev/null || echo "$0")
      server=""

      IFS=: read -ra dirs <<< "''${PATH:-}"
      for dir in "''${dirs[@]}"; do
        candidate="$dir/${srv.exe}"
        [ -x "$candidate" ] || continue

        resolved=$(${pkgs.coreutils}/bin/realpath "$candidate" 2>/dev/null || echo "$candidate")

        case "$resolved" in
          *-lspmux) continue ;;
        esac
        [ "$resolved" = "$self" ] && continue

        server="$resolved"
        break
      done

      [ -n "$server" ] || server=${lib.escapeShellArg fallback}

      # `--` is load-bearing: SERVER_ARGS is a bare positional in lspmux's parser,
      # so without it a server flag (--stdio, serve) is parsed as an lspmux flag.
      exec ${lib.getExe cfg.lspmux.package} client --server-path "$server" -- "$@"
    '';

  resolve =
    srv:
    let
      multiplexed = cfg.lspmux.enable && srv.multiplex;
    in
    {
      inherit (srv)
        args
        env
        exe
        extensionToLanguage
        initialization
        opencode
        ;
      command = if multiplexed then "${mkShim srv}" else "${srv.package}/bin/${srv.exe}";
      extensions = lib.attrNames srv.extensionToLanguage;
    };

  configFile = (pkgs.formats.toml { }).generate "lspmux-config.toml" cfg.lspmux.settings;
in
{
  options.x.home.development.lsp = {
    enable = mkEnabledOption "enable the shared language server registry";

    servers = lib.mkOption {
      type = lib.types.attrsOf serverType;
      default = { };
      description = ''
        Language servers registered by the modules that install them, keyed by
        language. Consumed by the AI agent modules; each entry is only present
        when the module contributing it is enabled.
      '';
    };

    resolved = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      internal = true;
      default = { };
      description = ''
        `servers` with each `command` resolved to an absolute path — the lspmux
        shim when multiplexing is on, the raw binary otherwise.
      '';
    };

    lspmux = {
      enable = mkEnabledOption "run language servers under lspmux";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.lspmux;
        defaultText = lib.literalExpression "pkgs.lspmux";
        description = "lspmux package providing the daemon and client.";
      };

      settings = lib.mkOption {
        type = (pkgs.formats.toml { }).type;
        description = "Settings written to lspmux's config.toml.";
        default = {
          listen = address;
          connect = address;
          instance_timeout = 300;
          gc_interval = 10;
          log_filters = "info";

          # PATH matters most: it is how a server finds its own toolchain, and it
          # is part of lspmux's instance key, so two projects with different
          # toolchains get separate server instances instead of sharing one.
          pass_environment = [
            "*"
            "!SHLVL"
            "!GPG_TTY"
            "!STARSHIP_SESSION_KEY"
            "!DIRENV_DIFF"
            "!DIRENV_WATCHES"
            "!DISPLAY"
            "!TMPDIR"
            "!NVIM"
          ];
        };
      };
    };
  };

  config = lib.mkMerge [
    {
      x.home.development.lsp.resolved = lib.optionalAttrs (
        config.x.home.development.enable && cfg.enable
      ) (lib.mapAttrs (_: resolve) cfg.servers);
    }

    (lib.mkIf (config.x.home.development.enable && cfg.enable && cfg.lspmux.enable) {
      home.packages = [ cfg.lspmux.package ];

      # `directories`, the crate lspmux reads its config with, uses
      # ~/Library/Application Support on darwin rather than XDG.
      xdg.configFile."lspmux/config.toml" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        source = configFile;
      };
      home.file."Library/Application Support/lspmux/config.toml" =
        lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
          {
            source = configFile;
          };

      systemd.user.services = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        lspmux = {
          Unit = {
            Description = "lspmux language server multiplexer";
            After = [ "network.target" ];
          };
          Service = {
            ExecStart = "${cfg.lspmux.package}/bin/lspmux server";
            Restart = "always";
            RestartSec = 5;
          };
          Install.WantedBy = [ "default.target" ];
        };
      };

      launchd.agents = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        lspmux = {
          enable = true;
          config = {
            ProgramArguments = [
              "${cfg.lspmux.package}/bin/lspmux"
              "server"
            ];
            KeepAlive = true;
            RunAtLoad = true;
            ProcessType = "Background";
            StandardOutPath = "/tmp/lspmux.log";
            StandardErrorPath = "/tmp/lspmux.log";
          };
        };
      };
    })
  ];
}
