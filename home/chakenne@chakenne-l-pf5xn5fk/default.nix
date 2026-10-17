{ user, ... }:
{
  imports = [ ../../profiles/work ];

  x.profile.workstation = true;
  x.profile.work = true;

  targets.genericLinux.enable = true;

  # TODO: before switching to niri need /run/opengl-driver (sudo non-nixos-gpu-setup)
  # remove refresh from monitor mode
  x.home.desktop.backend = "hyprland";

  x.home.desktop.idle.ubuntu-hyprlock-pkg = true;

  x.home.desktop.hyprland = {
    keyboardOptionsByDevice.at-translated-set-2-keyboard = [
      "ctrl:nocaps"
      "altwin:swap_lalt_lwin"
    ];

    decoration.blur = {
      size = 6;
      passes = 1;
      newOptimizations = true;
      xray = true;
    };

    render.newRenderScheduling = true;

    animations.workspace = {
      enabled = true;
      speed = 3;
      style = "fade";
    };

    lidSwitch = {
      enable = true;
      internalMonitor = "eDP-1";
      internalMonitorRule = "eDP-1,2880x1800@120,auto,1.5";
      preferredExternalMonitor = "DP-1";
    };

    monitors = [
      {
        output = "eDP-1";
        mode = "2880x1800@120";
        position = "auto";
        scale = 1.5;
      }
      {
        output = "DP-1";
        mode = "5120x2880@60";
        position = "auto";
        scale = 1.25;
      }
    ];
  };

  home.stateVersion = "22.11";
  home.homeDirectory = "/home/${user}";

}
