{
  self,
  config,
  pkgs,
  lib,
  homeDir,
  variant,
  ...
}:
let
  cfg = config.x.home.desktop.hyprland;

  inherit (self.lib)
    types
    mkEnabledOption
    mkOption
    ;

  uwsmApp = lib.optionalString cfg.uwsm.enable "uwsm app -- ";
  displayConfigurator = config.x.home.graphics.wrapPackage pkgs.wdisplays;
  whichKey = config.x.home.graphics.wrapPackage pkgs.wlr-which-key;
  hyprPersist = pkgs.x.hypr-persist;
  systemctl =
    if variant == "linux" then "/usr/bin/systemctl" else lib.getExe' pkgs.systemd "systemctl";
  yamlFormat = pkgs.formats.yaml { };
  tomlFormat = pkgs.formats.toml { };
  lua = lib.generators.mkLuaInline;
  toLua = lib.generators.toLua { };

  luaBind = keys: dispatcher: flags: {
    _args = [
      keys
      (lua dispatcher)
    ]
    ++ lib.optional (flags != { }) flags;
  };

  exec = command: "hl.dsp.exec_cmd(${toLua command})";

  wallpaper = "${homeDir}/.dotfiles/assets/philly-dark.jpg";

  workspaceAnimation =
    let
      workspace = cfg.animations.workspace;
    in
    if workspace.enabled == false then
      {
        leaf = "workspaces";
        enabled = false;
      }
    else
      {
        leaf = "workspaces";
        enabled = true;
        speed = workspace.speed;
        bezier = workspace.curve;
      }
      // lib.optionalAttrs (workspace.style != null) {
        style = workspace.style;
      };

  globalAnimation = {
    leaf = "global";
    enabled = true;
    speed = cfg.animations.globalSpeed;
    bezier = cfg.animations.globalCurve;
  };

  animationRules = [
    globalAnimation
  ]
  ++ cfg.animations.rules
  ++ lib.optionals (cfg.animations.workspace.enabled != null) [
    workspaceAnimation
  ];

  applyWallpaper = pkgs.writeShellApplication {
    name = "hyprpaper-apply-wallpaper";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.coreutils
      pkgs.gnugrep
    ];
    text = ''
      for _ in $(seq 1 60); do
        hyprctl hyprpaper wallpaper "${cfg.wallpaperMonitor},${wallpaper}" 2>/dev/null || true
        if hyprctl hyprpaper listactive 2>/dev/null | grep -qF "${wallpaper}"; then
          exit 0
        fi
        sleep 0.5
      done
    '';
  };

  handleLidSwitch = pkgs.writeShellApplication {
    name = "hyprland-lid-switch";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.jq
    ];
    text = self.lib.templateFile {
      file = ./lid-switch.sh;
      data = {
        INTERNAL_MONITOR = lib.escapeShellArg cfg.lidSwitch.internalMonitor;
        INTERNAL_MONITOR_RULE = lib.escapeShellArg cfg.lidSwitch.internalMonitorRule;
        PREFERRED_EXTERNAL_MONITOR = lib.escapeShellArg cfg.lidSwitch.preferredExternalMonitor;
      };
    };
  };

  screenshot = pkgs.writeShellApplication {
    name = "hyprland-screenshot";
    runtimeInputs = with pkgs; [
      coreutils
      grim
      libnotify
      slurp
      wl-clipboard
      xdg-user-dirs
    ];
    text = ''
      mode="$1"
      pictures="$(xdg-user-dir PICTURES 2>/dev/null || true)"
      if [[ -z "$pictures" ]]; then
        pictures="$HOME/Pictures"
      fi

      directory="$pictures/Screenshots"
      file="$directory/Screenshot $(date '+%Y-%m-%d at %H-%M-%S').png"
      mkdir -p "$directory"

      case "$mode" in
        full)
          grim "$file"
          ;;
        region)
          geometry="$(slurp)" || exit 0
          [[ -n "$geometry" ]] || exit 0
          grim -g "$geometry" "$file"
          ;;
        *)
          echo "Usage: hyprland-screenshot {full|region}" >&2
          exit 2
          ;;
      esac

      wl-copy --type image/png < "$file"
      notify-send "Screenshot captured" "$file"
    '';
  };

  powerAction = pkgs.writeShellApplication {
    name = "hyprland-power-action";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.libnotify
      pkgs.systemd
    ];
    text = ''
      action="$1"

      report_failure() {
        message="$1"
        printf '%s\n' "$message" >&2
        systemd-cat --identifier=hyprland-power-action printf '%s\n' "$message"
        notify-send --urgency=critical "Power action failed" "$message"
      }

      run_after_save() {
        ${lib.getExe hyprPersist} save
        ${systemctl} --user stop hypr-persist.service
        if ! "$@"; then
          ${systemctl} --user start hypr-persist.service
          return 1
        fi
      }

      case "$action" in
        logout)
          run_after_save hyprctl dispatch 'hl.dsp.exit()' || report_failure "Hyprland logout failed"
          ;;
        sleep)
          ${systemctl} suspend || report_failure "System suspend failed; check journalctl and logind permissions"
          ;;
        shutdown)
          run_after_save ${systemctl} poweroff || report_failure "System shutdown failed"
          ;;
        reboot)
          run_after_save ${systemctl} reboot || report_failure "System reboot failed"
          ;;
        *)
          echo "Usage: hyprland-power-action {logout|sleep|shutdown|reboot}" >&2
          exit 2
          ;;
      esac
    '';
  };

  confirmPowerAction = action: [
    {
      key = "y";
      desc = "Yes";
      cmd = "${lib.getExe powerAction} ${action}";
    }
    {
      key = "n";
      desc = "No";
      cmd = "${lib.getExe' pkgs.coreutils "true"}";
    }
  ];
in
{
  options.x.home.desktop.hyprland = {
    xwayland.enable = mkEnabledOption "enable Hyprland xwayland support.";
    uwsm.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Run Hyprland through UWSM.";
    };

    wallpaperMonitor = mkOption {
      type = types.str;
      default = "";
      description = "Monitor selector used when applying the Hyprpaper wallpaper.";
    };

    scale = mkOption {
      type = types.ints.u8;
      default = 1;
      description = "GDK scaling factor.";
    };

    keyboardOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "ctrl:nocaps" ];
      description = "XKB options for all Hyprland keyboard input devices.";
    };

    keyboardOptionsByDevice = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = { };
      example = {
        "at-translated-set-2-keyboard" = [
          "ctrl:nocaps"
          "altwin:swap_lalt_lwin"
        ];
      };
      description = "XKB options keyed by Hyprland keyboard device name.";
    };

    monitors = mkOption {
      type = types.listOf (
        types.attrsOf (
          types.oneOf [
            types.bool
            types.int
            types.float
            types.str
          ]
        )
      );
      default = [
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        }
      ];
      description = "Hyprland monitor rules.";
    };

    workspaces = mkOption {
      type = types.listOf (
        types.attrsOf (
          types.oneOf [
            types.bool
            types.int
            types.float
            types.str
          ]
        )
      );
      default = [ ];
      description = "Hyprland workspace rules.";
    };

    decoration = {
      rounding = mkOption {
        type = types.int;
        default = 12;
        description = "Window corner rounding radius.";
      };

      activeOpacity = mkOption {
        type = types.number;
        default = 1.0;
        description = "Opacity for active windows.";
      };

      inactiveOpacity = mkOption {
        type = types.number;
        default = 1.0;
        description = "Opacity for inactive windows.";
      };

      fullscreenOpacity = mkOption {
        type = types.number;
        default = 1.0;
        description = "Opacity for fullscreen windows.";
      };

      blur = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Hyprland window background blur.";
        };

        size = mkOption {
          type = types.int;
          default = 16;
          description = "Hyprland blur size.";
        };

        passes = mkOption {
          type = types.int;
          default = 3;
          description = "Hyprland blur pass count.";
        };

        newOptimizations = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Hyprland's optimized blur path.";
        };

        xray = mkOption {
          type = types.bool;
          default = false;
          description = "Allow floating window blur to ignore tiled windows.";
        };
      };
    };

    render = {
      newRenderScheduling = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Hyprland's new render scheduling path.";
      };

      device = mkOption {
        type = types.str;
        default = "";
        description = "GPU Hyprland renders on";
      };
    };

    animations = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Hyprland animations.";
      };

      workspaceWraparound = mkOption {
        type = types.bool;
        default = false;
        description = "Enable wraparound behavior for directional workspace animations.";
      };

      globalSpeed = mkOption {
        type = types.int;
        default = 3;
        description = "Base animation duration in deciseconds; every rule inherits it.";
      };

      globalCurve = mkOption {
        type = types.str;
        default = "default";
        description = "Bezier curve inherited by every animation rule.";
      };

      bezier = mkOption {
        type = types.listOf types.attrs;
        default = [ ];
        description = "Custom Hyprland animation curve definitions.";
      };

      rules = mkOption {
        type = types.listOf types.attrs;
        default = [ ];
        description = "Additional Hyprland animation rules.";
      };

      workspace = {
        enabled = mkOption {
          type = types.nullOr types.bool;
          default = null;
          description = "Workspace animation state; null leaves Hyprland's default rule in place.";
        };

        speed = mkOption {
          type = types.int;
          default = 8;
          description = "Workspace animation duration in deciseconds.";
        };

        curve = mkOption {
          type = types.str;
          default = "default";
          description = "Workspace animation bezier curve name.";
        };

        style = mkOption {
          type = types.nullOr (
            types.enum [
              "slide"
              "slidevert"
              "fade"
              "slidefade"
              "slidefadevert"
            ]
          );
          default = null;
          description = "Workspace animation style; null uses Hyprland's default style.";
        };
      };
    };

    lidSwitch = {
      enable = lib.mkEnableOption "external-monitor laptop lid handling";

      switchName = mkOption {
        type = types.str;
        default = "Lid Switch";
        description = "Hyprland switch device name for the laptop lid.";
      };

      internalMonitor = mkOption {
        type = types.str;
        default = "eDP-1";
        description = "Internal laptop monitor name.";
      };

      internalMonitorRule = mkOption {
        type = types.str;
        default = "eDP-1,preferred,auto,1";
        description = "Monitor rule used to re-enable the internal laptop panel.";
      };

      preferredExternalMonitor = mkOption {
        type = types.str;
        default = "";
        description = "External monitor to prefer when the lid closes; empty uses the first active external output.";
      };
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "extra configuration for Hyprland";
    };

    # TODO: move this higher up!
    theme = {
      activeBorderColor = lib.mkOption {
        type = lib.types.str;
        default = "ff69b4";
      };

      inactiveBorderColor = lib.mkOption {
        type = lib.types.str;
        default = "dddddd";
      };
    };
  };

  imports = [
    ./cursor.nix
    ./greetd.nix
    ./hypridle.nix
    ./hyprpaper.nix
    ./monitor-profiles.nix
  ];

  config = lib.mkIf (config.x.home.desktop.backend == "hyprland") {
    home.packages = [
      displayConfigurator
      hyprPersist
      whichKey
    ];

    xdg.configFile."hypr/hypr-persist.toml".source = tomlFormat.generate "hypr-persist.toml" {
      general = {
        save_interval = 120;
        session_dir = "~/.local/share/hypr-persist";
        restore_on_start = true;
        per_window_launch = true;
        restore_geometry = true;
        restore_layout = true;
      };
      rules.exclude = [
        "^xdg-desktop-portal.*"
        "^org\\.kde\\.polkit.*"
      ];
    };

    xdg.configFile."wlr-which-key/config.yaml".source =
      yamlFormat.generate "wlr-which-key-config.yaml"
        {
          font = "FiraCode Nerd Font 14";
          background = "#1A426Eee";
          color = "#ffffffff";
          border = "#ff69b4ff";
          border_width = 2;
          corner_r = 12;
          padding = 20;
          column_padding = 28;
          separator = " -> ";
          anchor = "center";
          inhibit_compositor_keyboard_shortcuts = true;
          auto_kbd_layout = true;
          menu = [
            {
              key = "d";
              desc = "Displays";
              cmd = "${uwsmApp}${lib.getExe displayConfigurator}";
            }
            {
              key = "p";
              desc = "Power";
              submenu = [
                {
                  key = "o";
                  desc = "Logout";
                  submenu = confirmPowerAction "logout";
                }
                {
                  key = "s";
                  desc = "Sleep";
                  submenu = confirmPowerAction "sleep";
                }
                {
                  key = "l";
                  desc = "Lock";
                  cmd = cfg.hypridle.lockCommand;
                }
                {
                  key = "q";
                  desc = "Shutdown";
                  submenu = confirmPowerAction "shutdown";
                }
                {
                  key = "r";
                  desc = "Reboot";
                  submenu = confirmPowerAction "reboot";
                }
              ];
            }
          ];
        };

    systemd.user.services.hypr-persist = {
      Unit = {
        Description = "Hyprland session persistence";
        After = [ "hyprland-session.target" ];
        PartOf = [ "hyprland-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = lib.getExe hyprPersist;
        Restart = "on-failure";
        RestartSec = 2;
        TimeoutStopSec = 30;
      };
      Install.WantedBy = [ "hyprland-session.target" ];
    };

    systemd.user.services.hyprpaper = lib.mkIf cfg.hyprpaper.enable {
      Service.ExecStartPost = lib.getExe applyWallpaper;
    };

    wayland.windowManager.hyprland = {
      enable = true;

      configType = "lua";
      package = config.x.home.graphics.wrapPackage pkgs.hyprland;

      systemd = {
        # UWSM owns the graphical session and conflicts with this integration.
        enable = !cfg.uwsm.enable;
        variables = [
          "DISPLAY"
          "GDK_SCALE"
          "HYPRLAND_INSTANCE_SIGNATURE"
          "WAYLAND_DISPLAY"
          "XCURSOR_PATH"
          "XCURSOR_SIZE"
          "XCURSOR_THEME"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_TYPE"
        ];
      };

      xwayland.enable = cfg.xwayland.enable;

      settings = {
        device = lib.mapAttrsToList (name: keyboardOptions: {
          inherit name;
          kb_options = lib.concatStringsSep "," keyboardOptions;
        }) cfg.keyboardOptionsByDevice;

        config = {
          input = {
            kb_layout = "us";
            repeat_rate = 50;
            repeat_delay = 200;
          }
          // lib.optionalAttrs (cfg.keyboardOptions != [ ]) {
            kb_options = lib.concatStringsSep "," cfg.keyboardOptions;
          };

          general = {
            col = {
              active_border = "rgb(${cfg.theme.activeBorderColor})";
              inactive_border = "rgb(${cfg.theme.inactiveBorderColor})";
            };
            resize_on_border = true;
          };

          dwindle.preserve_split = true;

          debug = lib.optionalAttrs cfg.uwsm.enable {
            disable_logs = false;
          };

          decoration = {
            rounding = cfg.decoration.rounding;
            active_opacity = cfg.decoration.activeOpacity;
            inactive_opacity = cfg.decoration.inactiveOpacity;
            fullscreen_opacity = cfg.decoration.fullscreenOpacity;

            blur = {
              enabled = cfg.decoration.blur.enable;
              passes = cfg.decoration.blur.passes;
              size = cfg.decoration.blur.size;
              new_optimizations = cfg.decoration.blur.newOptimizations;
              xray = cfg.decoration.blur.xray;
            };
          };

          render.new_render_scheduling = cfg.render.newRenderScheduling;

          animations = {
            enabled = cfg.animations.enable;
            workspace_wraparound = cfg.animations.workspaceWraparound;
          };

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            force_default_wallpaper = 0;
          };
        };

        on = lib.optionals cfg.lidSwitch.enable [
          {
            _args = [
              "hyprland.start"
              (lua ''
                function()
                  hl.exec_cmd(${toLua "${lib.getExe handleLidSwitch} reconcile"})
                end
              '')
            ];
          }
        ];

        monitor = cfg.monitors;

        bind = [
          (luaBind "SUPER + SPACE"
            (exec "${uwsmApp}${lib.getExe (config.x.home.graphics.wrapPackage pkgs.vicinae)} toggle")
            { }
          )
          (luaBind "SUPER + P"
            (exec "${uwsmApp}${lib.getExe (config.x.home.graphics.wrapPackage pkgs.vicinae)} 'vicinae://launch/@bl4zee1g/store.vicinae.bitwarden/browse-vault?toggle=true'")
            { }
          )
          (luaBind "SUPER + RETURN" (exec "${uwsmApp}alacritty") { })
          (luaBind "SUPER + Q" "hl.dsp.window.close()" { })
          (luaBind "SUPER + W" (exec "${lib.getExe pkgs.wtype} -M ctrl -k w -m ctrl") { })
          (luaBind "SUPER + BACKSPACE" (exec "${lib.getExe pkgs.wtype} -k ctrl+shift+left ctrl+x") { })
          (luaBind "SUPER + DELETE" (exec "${lib.getExe pkgs.wtype} -k ctrl+shift+left ctrl+x") { })
          (luaBind "SUPER + A" (exec "${lib.getExe pkgs.wtype} -M ctrl -k a -m ctrl") { })
          (luaBind "SUPER + X" (exec "${lib.getExe pkgs.wtype} -M ctrl -k x -m ctrl") { })
          (luaBind "SUPER + Z" (exec "${lib.getExe pkgs.wtype} -M ctrl -k z -m ctrl") { })
          (luaBind "SUPER + SHIFT + E" (exec "${lib.getExe powerAction} logout") { })
          (luaBind "SUPER + SHIFT + 3" (exec "${lib.getExe screenshot} full") { })
          (luaBind "SUPER + SHIFT + 4" (exec "${lib.getExe screenshot} region") { })
          (luaBind "CTRL + grave" (exec "${uwsmApp}${lib.getExe whichKey}") { })
          (luaBind "ALT + F" "hl.dsp.window.float()" { })
          (luaBind "SUPER + SHIFT + DELETE" (exec "hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'")
            { }
          )
          (luaBind "ALT + L" "hl.dsp.window.cycle_next()" { })
          (luaBind "ALT + L" ''hl.dsp.window.alter_zorder({ mode = "top" })'' { })
          (luaBind "ALT + H" "hl.dsp.window.cycle_next({ next = false })" { })
          (luaBind "ALT + H" ''hl.dsp.window.alter_zorder({ mode = "top" })'' { })
          (luaBind "ALT + SHIFT + N" "hl.dsp.window.swap({ next = true })" { })
          (luaBind "ALT + SHIFT + P" "hl.dsp.window.swap({ prev = true })" { })
        ]
        ++ lib.optionals cfg.lidSwitch.enable [
          (luaBind "switch:on:${cfg.lidSwitch.switchName}" (exec "${lib.getExe handleLidSwitch} closed") {
            locked = true;
          })
          (luaBind "switch:off:${cfg.lidSwitch.switchName}" (exec "${lib.getExe handleLidSwitch} open") {
            locked = true;
          })
        ]
        ++ [
          (luaBind "XF86AudioMute" (exec "ashell msg volume-toggle-mute") { locked = true; })
          (luaBind "XF86AudioRaiseVolume" (exec "ashell msg volume-up") {
            locked = true;
            repeating = true;
          })
          (luaBind "XF86AudioLowerVolume" (exec "ashell msg volume-down") {
            locked = true;
            repeating = true;
          })
          (luaBind "ALT + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
        ];

        env = [
          {
            _args = [
              "GDK_SCALE"
              (toString cfg.scale)
            ];
          }
          {
            _args = [
              "XCURSOR_SIZE"
              (toString (cfg.scale * 24))
            ];
          }
        ]
        ++ lib.optional (cfg.render.device != "") {
          _args = [
            "AQ_DRM_DEVICES"
            cfg.render.device
          ];
        };

        workspace_rule = cfg.workspaces;
      }
      // lib.optionalAttrs (cfg.animations.bezier != [ ]) {
        curve = map (curve: {
          _args = [
            curve.name
            (removeAttrs curve [ "name" ])
          ];
        }) cfg.animations.bezier;
      }
      // lib.optionalAttrs (animationRules != [ ]) {
        animation = animationRules;
      };

      extraConfig = cfg.extraConfig;
    };
  };
}
