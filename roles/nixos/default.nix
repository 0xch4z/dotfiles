{config, pkgs, homeDir, self, ...}: {
  imports = [
    ../common
  ];

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload = [ "${homeDir}/.dotfiles/assets/philly-dark.jpg" ];

      wallpaper = [ "${homeDir}/.dotfiles/assets/philly-dark.jpg" ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;

    #enableNvidiaPatches = true;

    xwayland.enable = true;

    settings = {
      exec-once = [
        "hyprpaper"
        "hyprctl setcursor Qogir 24"
        "waybar"
        "mako"
      ];

      monitor = [
        "HDMI-A-2,3840x2160@144,0x0,1"
        "DP-4,3840x2160@144,0x-2160,1"
      ];

      bind = [
        # launcher
        "SUPER,SPACE,exec,wofi --show drun"
        # terminal
        "SUPER,RETURN,exec,alacritty"
        # quit
        "SUPER,Q,killactive"
        # copy
        "SUPER,C,exec,wl-copy"
        # paste
        "SUPER,V,exec,wl-paste | wl-copy"
        # exit to tty
        "SUPER SHIFT,E,exit,"
      ];

      decoration = {
        rounding = 3;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        fullscreen_opacity = 1.0;
        #drop_shadow = false;

        blur = {
          enabled = true;
          passes = 3;
          size = 16;
        };
      };

      misc = {
        disable_hyprland_logo = true;
        force_default_wallpaper = 0;
      };
    };
  };

  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        disable_loading_bar = true;
        immediate_render = true;
        hide_cursor = false;
        no_fade_in = true;
      };

      animation = [
        "inputFieldDots, 1, 2, linear"
        "fadeIn, 0"
      ];

      background = [
        # {
        #   monitor = "";
        #   color = "rgb(0,0,0)";
        # }
      ];

      input-field = [
        {
          monitor = "";

          size = "300, 50";
          valign = "bottom";
          position = "0%, 10%";

          outline_thickness = 1;

          font_color = "rgb(b6c4ff)";
          outer_color = "rgba(180, 180, 180, 0.5)";
          inner_color = "rgba(200, 200, 200, 0.1)";
          check_color = "rgba(247, 193, 19, 0.5)";
          fail_color = "rgba(255, 106, 134, 0.5)";

          fade_on_empty = false;
          placeholder_text = "Enter Password";

          dots_spacing = 0.2;
          dots_center = true;
          dots_fade_time = 100;

          shadow_color = "rgba(0, 0, 0, 0.1)";
          shadow_size = 7;
          shadow_passes = 2;
        }
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 150;
          color = "rgb(b6c4ff)";

          position = "0%, 30%";

          valign = "center";
          halign = "center";

          shadow_color = "rgba(0, 0, 0, 0.1)";
          shadow_size = 20;
          shadow_passes = 2;
          shadow_boost = 0.3;
        }
        {
          monitor = "";
          text = "cmd[update:3600000] date +'%a %b %d'";
          font_size = 20;
          color = "rgb(b6c4ff)";

          position = "0%, 40%";

          valign = "center";
          halign = "center";

          shadow_color = "rgba(0, 0, 0, 0.1)";
          shadow_size = 20;
          shadow_passes = 2;
          shadow_boost = 0.3;
        }
      ];
    };
  };

  programs.waybar.enable = true;
  services.mako.enable = true;

  home = {
    packages = with pkgs; [
      git
    ];

    sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        WLR_NO_HARDWARE_CURSORS = "1";
        GDK_SCALE = "1";
        GDK_DPI_SCALE = "1";
        QT_AUTO_SCREEN_SCALE_FACTOR = "0";
        QT_SCALE_FACTOR = "1";
        XCURSOR_SIZE = "24";
    };

    shellAliases = {
    };
  };
}
