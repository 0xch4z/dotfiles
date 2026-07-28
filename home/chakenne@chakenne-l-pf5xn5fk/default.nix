{ user, ... }:
{
  imports = [ ../../profiles/work ];

  x.profile.workstation = true;
  x.profile.work = true;

  x.home.graphics.nixGL = {
    enable = true;
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
    vulkan.enable = false;
  };

  x.home.desktop.hyprland = {
    keyboardOptionsByDevice.at-translated-set-2-keyboard = [
      "ctrl:nocaps"
      "altwin:swap_lalt_lwin"
    ];

    monitors = [
      "eDP-1,2880x1800@120,auto,1.5" # builtin
      "DP-1,5120x2880@60,auto,1.25" # apple studio display
    ];
  };

  home.stateVersion = "22.11";
  home.homeDirectory = "/home/${user}";

}
