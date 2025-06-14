{config, pkgs, homeDir, self, ...}: {
  imports = [
    ../common
  ];

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      splash_offset = 2.0;

      preload = [ "${homeDir}/.dotfiles/assets/philly-dark.jpg" ];

      wallpaper = [ "${homeDir}/.dotfiles/assets/philly-dark.jpg" ];
    };
  };

  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        disable_loading_bar = true;
        immediate_render = true;
        hide_cursor = true;
        no_fade_in = true;
        grace = 5;
      };

      animation = [
        "inputFieldDots, 1, 2, linear"
        "fadeIn, 0"
      ];

      background = {
          color = "rgba(25, 20, 20, 1.0)";
          blur_passes = 2;
          brightness = 0.5;
      };

      input-field = [
        {
          size = "300, 50";
          valign = "bottom";
          position = "0%, 10%";
          placeholder_text = "password";

          outline_thickness = 1;

          font_color = "rgb(b6c4ff)";
          outer_color = "rgba(180, 180, 180, 0.5)";
          inner_color = "rgba(200, 200, 200, 0.1)";
          check_color = "rgba(247, 193, 19, 0.5)";
          fail_color = "rgba(255, 106, 134, 0.5)";

          fade_on_empty = false;

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
