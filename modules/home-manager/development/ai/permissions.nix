{
  self,
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (self.lib) mkEnabledOption;
  cfg = config.x.home.development.ai.permissions;

  effect = lib.types.enum [
    "allow"
    "ask"
    "deny"
  ];

  bashBy = want: lib.attrNames (lib.filterAttrs (_: e: e == want) cfg.bash);
  bashExactBy = want: lib.attrNames (lib.filterAttrs (_: e: e == want) cfg.bashExact);

  claudeTools = {
    edit = [
      "Edit"
      "MultiEdit"
      "NotebookEdit"
    ];
    read = [
      "Read"
      "Glob"
      "Grep"
    ];
    write = [ "Write" ];
    webfetch = [ "WebFetch" ];
    websearch = [ "WebSearch" ];
  };

  opencodeTools = {
    edit = "edit";
    webfetch = "webfetch";
    websearch = "websearch";
  };

  claudeToolsBy =
    want:
    lib.concatLists (
      lib.mapAttrsToList (
        verb: names: lib.optionals ((cfg.tools.${verb} or null) == want) names
      ) claudeTools
    );

  sorted = xs: lib.unique (lib.sort (a: b: a < b) xs);

  claudeBash =
    want: map (p: "Bash(${p}:*)") (bashBy want) ++ map (p: "Bash(${p})") (bashExactBy want);

  nonEmpty = lib.filterAttrs (_: v: v != [ ]);

  # Read by the agent itself, not by a harness — see the running-commands
  # section in context.nix.
  reference = {
    matching = {
      bash = "Literal prefix of the command line. Any arguments may follow, but the prefix must match exactly, flag order included: `gh api --method GET` matches `gh api --method GET /repos/x`, not `gh api /repos/x --method GET`.";
      bashExact = "Whole command. Takes no arguments.";
      unlisted = cfg.defaultBash;
    };

    bash = nonEmpty {
      allow = sorted (bashBy "allow");
      ask = sorted (bashBy "ask");
      deny = sorted (bashBy "deny");
    };

    bashExact = nonEmpty {
      allow = sorted (bashExactBy "allow");
      ask = sorted (bashExactBy "ask");
      deny = sorted (bashExactBy "deny");
    };

    inherit (cfg) tools readDirs denyPaths;
  };

  referencePath = "${config.xdg.configHome}/llm-agents/permissions.json";
in
{
  options.x.home.development.ai.permissions = {
    enable = mkEnabledOption "render one shared permission set into every agent harness";

    defaultBash = lib.mkOption {
      type = effect;
      default = "ask";
    };

    bash = lib.mkOption {
      type = lib.types.attrsOf effect;
      default = {
        # read-only utils
        "basename" = "allow";
        "cat" = "allow";
        "column" = "allow";
        "comm" = "allow";
        "cut" = "allow";
        "date" = "allow";
        "df" = "allow";
        "diff" = "allow";
        "dirname" = "allow";
        "du" = "allow";
        "fd" = "allow";
        "file" = "allow";
        "grep" = "allow";
        "head" = "allow";
        "hostname" = "allow";
        "jq" = "allow";
        "ls" = "allow";
        "ps" = "allow";
        "pgrep" = "allow";
        "readlink" = "allow";
        "realpath" = "allow";
        "rg" = "allow";
        "sort" = "allow";
        "stat" = "allow";
        "strings" = "allow";
        "tail" = "allow";
        "tree" = "allow";
        "tr" = "allow";
        "uname" = "allow";
        "uniq" = "allow";
        "wc" = "allow";
        "which" = "allow";
        "yq" = "allow";

        # git: read-only
        "git blame" = "allow";
        "git branch" = "allow";
        "git config --get" = "allow";
        "git config --list" = "allow";
        "git describe" = "allow";
        "git diff" = "allow";
        "git fetch" = "allow";
        "git grep" = "allow";
        "git log" = "allow";
        "git ls-files" = "allow";
        "git remote -v" = "allow";
        "git rev-parse" = "allow";
        "git shortlog" = "allow";
        "git show" = "allow";
        "git stash list" = "allow";
        "git status" = "allow";
        "git tag" = "allow";
        "git worktree list" = "allow";

        # gh: read-only
        "gh api --method GET" = "allow";
        "gh api -X GET" = "allow";
        "gh auth status" = "allow";
        "gh browse" = "allow";
        "gh issue list" = "allow";
        "gh issue status" = "allow";
        "gh issue view" = "allow";
        "gh pr checks" = "allow";
        "gh pr diff" = "allow";
        "gh pr list" = "allow";
        "gh pr status" = "allow";
        "gh pr view" = "allow";
        "gh release list" = "allow";
        "gh release view" = "allow";
        "gh repo list" = "allow";
        "gh repo view" = "allow";
        "gh run list" = "allow";
        "gh run view" = "allow";
        "gh run watch" = "allow";
        "gh search" = "allow";
        "gh workflow list" = "allow";
        "gh workflow view" = "allow";

        # lang toolchains
        "cargo build" = "allow";
        "cargo check" = "allow";
        "cargo clippy" = "allow";
        "cargo fmt" = "allow";
        "cargo metadata" = "allow";
        "cargo test" = "allow";
        "cargo tree" = "allow";
        "go build" = "allow";
        "go doc" = "allow";
        "go env" = "allow";
        "go list" = "allow";
        "go mod" = "allow";
        "go test" = "allow";
        "go vet" = "allow";
        "gofmt" = "allow";

        # nix
        "deadnix" = "allow";
        "darwin-rebuild build" = "allow";
        "nix build" = "allow";
        "nix derivation show" = "allow";
        "nix eval" = "allow";
        "nix flake check" = "allow";
        "nix flake metadata" = "allow";
        "nix flake show" = "allow";
        "nix log" = "allow";
        "nix path-info" = "allow";
        "nix search" = "allow";
        "nix why-depends" = "allow";
        "nix-instantiate" = "allow";
        "nixfmt" = "allow";
        "nixos-rebuild build" = "allow";
        "statix" = "allow";

        # cluster read-only
        "cilium status" = "allow";
        "cilium version" = "allow";
        "kubectl api-resources" = "allow";
        "kubectl cluster-info" = "allow";
        "kubectl config current-context" = "allow";
        "kubectl config get-contexts" = "allow";
        "kubectl describe" = "allow";
        "kubectl explain" = "allow";
        "kubectl get" = "allow";
        "kubectl logs" = "allow";
        "kubectl top" = "allow";

        # services
        "journalctl" = "allow";
        "launchctl list" = "allow";
        "launchctl print" = "allow";
        "systemctl --user status" = "allow";

        "sudo" = "deny";
      };
    };

    bashExact = lib.mkOption {
      type = lib.types.attrsOf effect;
      default = {
        "env" = "allow";
        "printenv" = "allow";
        "pwd" = "allow";
      };
    };

    tools = lib.mkOption {
      type = lib.types.attrsOf effect;
      default = {
        edit = "allow";
        read = "allow";
        write = "allow";
        webfetch = "allow";
        websearch = "allow";
      };
    };

    denyPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "./.env"
        "./.env.*"
        "./**/secrets/**"
        "./**/*.pem"
        "./**/*.key"
      ];
    };

    readDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/nix/store"
        "${config.home.homeDirectory}/.local/share/claude"
      ]
      ++ lib.optional pkgs.stdenv.hostPlatform.isDarwin "${config.home.homeDirectory}/Library/Caches/claude-cli-nodejs"
      ++ lib.optional pkgs.stdenv.hostPlatform.isLinux "${config.home.homeDirectory}/.cache/claude-cli-nodejs";
    };

    claudeDeny = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "Bash(rm -rf /:*)"
      ];
    };

    opencodeBash = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        "gh api * --method DELETE *" = "deny";
        "gh api * --method POST *" = "deny";
        "gh api * --method PUT *" = "deny";
        "gh api * -X DELETE *" = "deny";
        "gh api * -X POST *" = "deny";
        "gh api * -X PUT *" = "deny";
      };
    };

    rendered = {
      claude = lib.mkOption {
        type = lib.types.attrs;
        internal = true;
        default = { };
        description = "`permissions` as Claude Code's allow/ask/deny rule lists.";
      };

      opencode = lib.mkOption {
        type = lib.types.attrs;
        internal = true;
        default = { };
        description = "`permissions` as opencode's `permission` object.";
      };
    };
  };

  config = lib.mkIf (config.x.home.development.enable && cfg.enable) {
    # A store symlink, so it is read-only without setting a mode.
    xdg.configFile."llm-agents/permissions.json".source =
      (pkgs.formats.json { }).generate "agent-permissions.json"
        reference;

    x.home.development.ai.context.sections.running-commands.text = lib.mkAfter ''
      ## Permissions

      What runs without interrupting me is listed in
      ${referencePath}, generated from the same source as each harness's
      permission config. Read it rather than guessing, and prefer a listed form
      over an equivalent one that isn't listed. `matching` in that file explains
      how an entry is compared against a command — prefixes are literal, so flag
      order matters.

      If a prompt interrupts a read-only command that will come up again, say so
      and name the entry to add; the rules live in
      modules/home-manager/development/ai/permissions.nix in my dotfiles. Don't
      suggest one for a one-off, or for anything that mutates state.
    '';

    x.home.development.ai.permissions.rendered = {
      claude = {
        additionalDirectories = cfg.readDirs;
        allow = sorted (claudeBash "allow" ++ claudeToolsBy "allow");
        ask = sorted (claudeBash "ask" ++ claudeToolsBy "ask");
        deny = sorted (
          claudeBash "deny"
          ++ claudeToolsBy "deny"
          ++ map (p: "Read(${p})") cfg.denyPaths
          ++ lib.optional (cfg.defaultBash == "deny") "Bash"
          ++ cfg.claudeDeny
        );
      };

      opencode = {
        bash = {
          "*" = cfg.defaultBash;
        }
        // lib.listToAttrs (
          lib.concatMap (p: [
            (lib.nameValuePair p cfg.bash.${p})
            (lib.nameValuePair "${p} *" cfg.bash.${p})
          ]) (lib.attrNames cfg.bash)
        )
        // cfg.bashExact
        // cfg.opencodeBash;
      }
      // lib.mapAttrs' (verb: name: lib.nameValuePair name cfg.tools.${verb}) (
        lib.filterAttrs (verb: _: cfg.tools ? ${verb}) opencodeTools
      );
    };
  };
}
