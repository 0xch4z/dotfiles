{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.x.home.taskbar.ashell;
in
{
  options.x.home.taskbar.ashell = {
    enable = lib.mkEnableOption "Enable ashell home-manager module.";
  };

  config = lib.mkIf cfg.enable {
    programs.ashell = {
      enable = true;
      package = self.inputs.ashell.packages.${pkgs.stdenv.hostPlatform.system}.default;
      systemd.enable = true;
      settings = {
        position = "Bottom";

        modules = {
          left = [
            "Workspaces"
            "SystemInfo"
          ];
          center = [ "WindowTitle" ];
          right = [
            "Tempo"
            [
              "Settings"
              "Privacy"
              "Notifications"
            ]
          ];
        };

        system_info.indicators = [
          "Cpu"
          "Memory"
        ];

        osd = {
          enabled = true;
          timeout = 1500;
          show_volume_percentage = true;
          show_brightness_percentage = true;
        };

        notifications = {
          enabled = true;
          show_timestamps = true;
          show_bodies = true;
          show_progress_bar = true;
          grouped = true;
          toast = true;
          toast_position = "bottom_right";
          toast_timeout = 5000;
          toast_limit = 5;
          toast_max_height = 150;
        };

        tempo = {
          clock_format = "%a %d %b %H:%M:%S";
          weather_location = "Current";
        };

        settings = {
          battery_format = "IconAndPercentage";
          peripheral_battery_format = "Icon";
          peripheral_indicators = {
            Specific = [
              "Gamepad"
              "Keyboard"
            ];
          };
          audio_indicator_format = "Icon";
          microphone_indicator_format = "Icon";
          network_indicator_format = "Icon";
          bluetooth_indicator_format = "Icon";
          bruh = true;
        };

        animations.enabled = true;
        appearance = {
          style = "Islands";
          opacity = 0.9;
          primary_color = "#FF69B4";
          background_color = {
            base = "#1A426E";
          };
          menu = {
            opacity = 0.9;
          };
        };
      };
    };

    systemd.user.services.ashell = {
      Unit.StartLimitIntervalSec = 0;
      Service = {
        Restart = lib.mkForce "always";
        RestartSec = 1;
        Environment = [
          "LD_LIBRARY_PATH=/run/opengl-driver/lib"
          "__EGL_VENDOR_LIBRARY_DIRS=/run/opengl-driver/share/glvnd/egl_vendor.d"
          "VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json"
        ];
      };
    };
  };
}
