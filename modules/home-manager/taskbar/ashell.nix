{ config, lib, pkgs, ... }:
let cfg = config.x.home.taskbar.ashell;
in {
  options.x.home.taskbar.ashell = {
    enable = lib.mkEnableOption "Enable ashell home-manager module.";
  };

  config = lib.mkIf cfg.enable {
    programs.ashell = {
      enable = true;
      settings = {
        position = "Bottom";

        modules = {
          left = [ "Workspaces" "SystemInfo" ];
          center = [ "WindowTitle" ];
          right = [ "Clock" ];
        };

        system_info.indicators = [ "Cpu" "Memory" ];

        clock.format = "%a %d %b  %H:%M";

        appearance = {
          style = "Islands";
          opacity = 0.9;
        };
      };
    };
  };
}
