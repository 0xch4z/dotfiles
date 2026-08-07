{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.x.home.desktop.hyprland;
  profilesEnabled = cfg.monitorProfiles != { };

  outputHook = pkgs.writeShellApplication {
    name = "hyprland-monitor-profile-output";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.hyprland
      pkgs.jq
      pkgs.util-linux
    ];
    text = ''
      profile="$1"
      output="$2"
      version="$3"
      shift 3

      state_dir="$XDG_RUNTIME_DIR/hyprland-monitor-profile"
      profile_key="$profile-$version"
      profile_dir="$state_dir/profiles/$profile_key"
      mkdir -p "$state_dir/profiles"

      exec 9>"$state_dir/lock"
      flock 9

      current="$(cat "$state_dir/current" 2>/dev/null || true)"
      if [ "$current" != "$profile_key" ]; then
        rm -rf "$state_dir/profiles"
        mkdir -p "$profile_dir"
        printf '%s\n' "$profile_key" >"$state_dir/current.tmp"
        mv "$state_dir/current.tmp" "$state_dir/current"
      else
        mkdir -p "$profile_dir"
      fi

      for workspace in "$@"; do
        printf '%s\n' "$output" >"$profile_dir/$workspace.tmp"
        mv "$profile_dir/$workspace.tmp" "$profile_dir/$workspace"
      done

      flock -u 9

      existing_workspaces="$(hyprctl workspaces -j | jq -r '.[].id')"
      for workspace in "$@"; do
        if printf '%s\n' "$existing_workspaces" | grep -qxF "$workspace"; then
          hyprctl dispatch moveworkspacetomonitor "$workspace" "$output" >/dev/null
        fi
      done
    '';
  };

  workspaceDispatch = pkgs.writeShellApplication {
    name = "hyprland-profile-workspace";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.jq
    ];
    text = ''
      action="$1"
      workspace="$2"
      state_dir="$XDG_RUNTIME_DIR/hyprland-monitor-profile"
      profile_key="$(cat "$state_dir/current" 2>/dev/null || true)"
      target="$(cat "$state_dir/profiles/$profile_key/$workspace" 2>/dev/null || true)"

      target_active=false
      if [ -n "$target" ] && hyprctl monitors -j | jq -e --arg target "$target" \
        'any(.[]; .name == $target)' >/dev/null; then
        target_active=true
      fi

      case "$action" in
        focus)
          if [ "$target_active" = true ]; then
            hyprctl dispatch focusmonitor "$target" >/dev/null
          fi
          hyprctl dispatch workspace "$workspace" >/dev/null
          ;;
        move)
          hyprctl dispatch movetoworkspacesilent "$workspace" >/dev/null
          if [ "$target_active" = true ]; then
            hyprctl dispatch moveworkspacetomonitor "$workspace" "$target" >/dev/null
          fi
          ;;
        *)
          echo "usage: hyprland-profile-workspace focus|move WORKSPACE" >&2
          exit 64
          ;;
      esac
    '';
  };

  profileType = lib.types.submodule {
    options.outputs = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            search = lib.mkOption {
              type = lib.types.either lib.types.str (lib.types.listOf lib.types.str);
              description = "Shikane display search expression.";
            };

            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to enable the matched display.";
            };

            mode = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Shikane output mode.";
            };

            position = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Position in Shikane's x,y format.";
            };

            scale = lib.mkOption {
              type = lib.types.nullOr lib.types.number;
              default = null;
              description = "Output scale.";
            };

            transform = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.enum [
                  "normal"
                  "90"
                  "180"
                  "270"
                  "flipped"
                  "flipped-90"
                  "flipped-180"
                  "flipped-270"
                ]
              );
              default = null;
              description = "Output transform.";
            };

            adaptiveSync = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = null;
              description = "Whether to enable adaptive sync.";
            };

            workspaces = lib.mkOption {
              type = lib.types.listOf lib.types.ints.positive;
              default = [ ];
              description = "Numbered workspaces owned by this output in this profile.";
            };
          };
        }
      );
      description = "Exact set of outputs in this Shikane profile.";
    };
  };

  profileVersion =
    profile:
    builtins.substring 0 16 (
      builtins.hashString "sha256" (builtins.toJSON (map (output: output.workspaces) profile.outputs))
    );

  shikaneProfiles = lib.mapAttrsToList (name: profile: {
    inherit name;
    output = map (
      output:
      lib.filterAttrs (_: value: value != null) {
        inherit (output)
          search
          enable
          mode
          position
          scale
          transform
          ;
        adaptive_sync = output.adaptiveSync;
        exec = [
          "${lib.getExe outputHook} ${lib.escapeShellArg name} \"$SHIKANE_OUTPUT_NAME\" ${profileVersion profile} ${
            lib.concatMapStringsSep " " toString output.workspaces
          }"
        ];
      }
    ) profile.outputs;
  }) cfg.monitorProfiles;

  profileAssertions = lib.mapAttrsToList (name: profile: {
    assertion =
      let
        workspaces = lib.concatMap (output: output.workspaces) profile.outputs;
      in
      lib.length workspaces == lib.length (lib.unique workspaces)
      && lib.all (output: output.enable || output.workspaces == [ ]) profile.outputs;
    message = "Hyprland monitor profile '${name}' assigns a workspace more than once or assigns workspaces to a disabled output.";
  }) cfg.monitorProfiles;
in
{
  options.x.home.desktop.hyprland.monitorProfiles = lib.mkOption {
    type = lib.types.attrsOf profileType;
    default = { };
    description = "Monitor-set profiles managed by Shikane, including workspace ownership.";
  };

  config = lib.mkIf (config.x.home.desktop.backend == "hyprland") {
    assertions = profileAssertions;

    services.shikane = lib.mkIf profilesEnabled {
      enable = true;
      settings = {
        timeout = 500;
        profile = shikaneProfiles;
      };
    };

    systemd.user.services.shikane = lib.mkIf profilesEnabled {
      Unit = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        StartLimitIntervalSec = 0;
      };
      Service = {
        Restart = "always";
        RestartSec = 1;
      };
    };

    wayland.windowManager.hyprland.settings = {
      monitor = lib.mkIf profilesEnabled (lib.mkForce [ ",preferred,auto,1" ]);
      workspace = lib.mkIf profilesEnabled (lib.mkForce [ ]);

      bind =
        map (workspace: "ALT,${toString workspace},workspace,${toString workspace}") (lib.range 1 9)
        ++ map (workspace: "ALT SHIFT,${toString workspace},movetoworkspacesilent,${toString workspace}") (
          lib.range 1 9
        );
    }
    // lib.optionalAttrs profilesEnabled {
      bind =
        map (
          workspace:
          "ALT,${toString workspace},exec,${lib.getExe workspaceDispatch} focus ${toString workspace}"
        ) (lib.range 1 9)
        ++ map (
          workspace:
          "ALT SHIFT,${toString workspace},exec,${lib.getExe workspaceDispatch} move ${toString workspace}"
        ) (lib.range 1 9);
    };
  };
}
