{
  config,
  pkgs,
  lib,
  self,
  homeDir,
  variant,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkIf
    mkOption
    types
    ;

  suspendTimeout = 3600;
  cfg = config.x.home.desktop.hyprland.hypridle;
  hyprlandEnabled = config.x.home.desktop.backend == "hyprland";
  font = config.x.home.theme.font.mono;
  wallpaper = "${homeDir}/.dotfiles/assets/philly-dark.jpg";

  ubuntuHyprlock = pkgs.writeShellApplication {
    name = "hyprlock";
    runtimeInputs = [ pkgs.libnotify ];
    text = ''
      if [[ ! -x /usr/bin/hyprlock ]]; then
        message="Ubuntu Hyprlock is not installed at /usr/bin/hyprlock"
        echo "$message" >&2
        notify-send --urgency=critical "Lock failed" "$message"
        exit 127
      fi

      if /usr/bin/hyprlock "$@"; then
        exit 0
      else
        status=$?
        message="Ubuntu Hyprlock exited with status $status; check its terminal output or journal"
        echo "$message" >&2
        notify-send --urgency=critical "Lock failed" "$message"
        exit "$status"
      fi
    '';
  };
  hyprlockPackage =
    if cfg.ubuntu-hyprlock-pkg then
      ubuntuHyprlock
    else
      config.x.home.graphics.wrapPackage pkgs.hyprlock;
  loginctl = if variant == "linux" then "/usr/bin/loginctl" else lib.getExe' pkgs.systemd "loginctl";
  systemctl =
    if variant == "linux" then "/usr/bin/systemctl" else lib.getExe' pkgs.systemd "systemctl";

  suspendGuard = pkgs.writeShellApplication {
    name = "hypridle-suspend-guard";
    runtimeInputs = with pkgs; [
      coreutils
    ];
    text = self.lib.templateFile {
      file = ./hypridle-suspend-guard.sh;
      data.SYSTEMCTL = systemctl;
    };
  };

  idleCtl = pkgs.writeShellApplication {
    name = "idle-ctl";
    runtimeInputs = with pkgs; [ coreutils ];
    text = self.lib.templateFile {
      file = ./idle-ctl.sh;
      data = {
        IDLE_SECONDS = toString suspendTimeout;
      };
    };
  };

  cscoTicker = pkgs.writeShellApplication {
    name = "hyprlock-csco-ticker";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      jq
    ];
    text = ''
      cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/hyprlock"
      cache_file="$cache_dir/csco-ticker"
      url="https://api.nasdaq.com/api/quote/CSCO/info?assetclass=stocks"

      if response="$(curl --fail --silent --location \
        --user-agent 'Mozilla/5.0' \
        --header 'Accept: application/json' \
        --connect-timeout 2 \
        --max-time 5 \
        "$url")" \
        && quote="$(jq -er '
          .data.primaryData
          | select(.lastSalePrice != null and .percentageChange != null)
          | "CSCO  \(.lastSalePrice)  \(.percentageChange)"
        ' <<< "$response")"; then
        mkdir -p "$cache_dir"
        printf '%s\n' "$quote" | tee "$cache_file"
      elif [[ -r "$cache_file" ]]; then
        cat "$cache_file"
      else
        printf 'CSCO  --\n'
      fi
    '';
  };
in
{
  options.x.home.desktop.hyprland.hypridle = {
    enable = mkOption {
      type = types.bool;
      default = hyprlandEnabled;
      defaultText = literalExpression "x.desktop.backend";
      description = "enable hypridle home-manager module";
    };

    ubuntu-hyprlock-pkg = mkOption {
      type = types.bool;
      default = false;
      description = "Use Ubuntu's /usr/bin/hyprlock instead of the Nix package.";
    };

    lockCommand = mkOption {
      type = types.str;
      readOnly = true;
      internal = true;
      default = lib.getExe hyprlockPackage;
      description = "Configured Hyprlock command.";
    };
  };

  config = lib.mkIf (hyprlandEnabled && cfg.enable) {
    home.packages = [ idleCtl ];

    programs.hyprlock = {
      enable = true;
      package = hyprlockPackage;
      settings = {
        general = {
          hide_cursor = true;
          ignore_empty_input = true;
        };

        background = [
          {
            monitor = "";
            path = wallpaper;
            blur_passes = 2;
            blur_size = 5;
            brightness = 0.68;
            contrast = 1.05;
            noise = 0.008;
            vibrancy = 0.18;
            vibrancy_darkness = 0.1;
          }
        ];

        shape = [
          {
            monitor = "";
            size = "520, 230";
            color = "rgba(6, 20, 38, 0.78)";
            rounding = 24;
            border_size = 1;
            border_color = "rgba(255, 105, 180, 0.55)";
            position = "0, -170";
            halign = "center";
            valign = "center";
            shadow_passes = 3;
            shadow_size = 12;
            shadow_color = "rgba(0, 0, 0, 0.55)";
            zindex = 0;
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "420, 62";
            position = "0, -170";
            halign = "center";
            valign = "center";
            outline_thickness = 3;
            rounding = 16;
            inner_color = "rgba(10, 32, 58, 0.88)";
            outer_color = "rgba(255, 105, 180, 0.95) rgba(0, 107, 182, 0.95) 45deg";
            check_color = "rgba(0, 107, 182, 0.95) rgba(255, 105, 180, 0.95) 45deg";
            fail_color = "rgba(255, 80, 110, 0.95)";
            capslock_color = "rgba(245, 132, 38, 0.95)";
            font_color = "rgb(240, 247, 255)";
            font_family = font;
            placeholder_text = "Password";
            check_text = "Unlocking...";
            fail_text = "<i>$FAIL</i>";
            dots_center = true;
            dots_size = 0.28;
            dots_spacing = 0.24;
            fade_on_empty = false;
            shadow_passes = 2;
            shadow_size = 6;
            shadow_color = "rgba(0, 0, 0, 0.45)";
            zindex = 1;
          }
        ];

        label = [
          {
            monitor = "";
            text = "$TIME";
            color = "rgb(240, 247, 255)";
            font_size = 92;
            font_family = font;
            position = "0, 310";
            halign = "center";
            valign = "center";
            shadow_passes = 3;
            shadow_size = 8;
            shadow_color = "rgba(0, 0, 0, 0.75)";
            zindex = 1;
          }
          {
            monitor = "";
            text = "cmd[update:60000] date '+%A, %B %-d'";
            color = "rgba(220, 235, 248, 0.9)";
            font_size = 20;
            font_family = font;
            position = "0, 235";
            halign = "center";
            valign = "center";
            shadow_passes = 2;
            shadow_size = 5;
            shadow_color = "rgba(0, 0, 0, 0.7)";
            zindex = 1;
          }
          {
            monitor = "";
            text = "$USER";
            color = "rgb(240, 247, 255)";
            font_size = 18;
            font_family = font;
            position = "0, -100";
            halign = "center";
            valign = "center";
            zindex = 1;
          }
          {
            monitor = "";
            text = "Enter your password to unlock";
            color = "rgba(190, 211, 230, 0.75)";
            font_size = 13;
            font_family = font;
            position = "0, -238";
            halign = "center";
            valign = "center";
            zindex = 1;
          }
          {
            monitor = "";
            text = "cmd[update:60000] ${lib.getExe cscoTicker}";
            color = "rgba(220, 235, 248, 0.85)";
            font_size = 16;
            font_family = font;
            position = "40, 40";
            halign = "right";
            valign = "bottom";
            shadow_passes = 2;
            shadow_size = 4;
            shadow_color = "rgba(0, 0, 0, 0.7)";
            zindex = 1;
          }
        ];
      };
    };

    # See: https://wiki.hyprland.org/Hypr-Ecosystem/hypridle
    services.hypridle = {
      enable = true;
      systemdTarget = "hyprland-session.target";

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || ${cfg.lockCommand}"; # enter hyprlock
          before_sleep_cmd = "${loginctl} lock-session"; # lock before suspend
          after_sleep_cmd = "hyprctl dispatch dpms on"; # turn screen on after key press
        };

        listener = [
          {
            timeout = 60; # 1min
            on-timeout = "brightnessctl -s set 10"; # set monitor backlight to min
            on-resume = "brightnessctl -r"; # restore monitor brightness
          }
          {
            timeout = 300; # 5min
            on-timeout = cfg.lockCommand;
          }
          {
            timeout = 330; # 5.5min
            on-timeout = "hyprctl dispatch dpms off"; # 5.5min
            on-resume = "hyprctl dispatch dpms on"; # screen off
          }
          {
            timeout = 3600; # 60min
            on-timeout = "${suspendGuard}/bin/hypridle-suspend-guard"; # guarded by idle-ctl
          }
        ];
      };
    };
  };
}
