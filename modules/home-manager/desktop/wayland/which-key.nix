{
  self,
  config,
  pkgs,
  lib,
  variant,
  ...
}:
let
  cfg = config.x.home.desktop.wayland;

  inherit (self.lib) types mkOption;

  yamlFormat = pkgs.formats.yaml { };

  systemctl =
    if variant == "linux" then "/usr/bin/systemctl" else lib.getExe' pkgs.systemd "systemctl";

  powerAction = pkgs.writeShellApplication {
    name = "desktop-power-action";
    runtimeInputs = [
      pkgs.libnotify
      pkgs.systemd
    ];
    text = ''
      action="$1"

      report_failure() {
        printf '%s\n' "$1" >&2
        notify-send --urgency=critical "Power action failed" "$1"
      }

      case "$action" in
        logout)
          ${cfg.exitCommand} || report_failure "Session logout failed"
          ;;
        sleep)
          ${systemctl} suspend || report_failure "System suspend failed"
          ;;
        shutdown)
          ${systemctl} poweroff || report_failure "System shutdown failed"
          ;;
        reboot)
          ${systemctl} reboot || report_failure "System reboot failed"
          ;;
        *)
          echo "Usage: desktop-power-action {logout|sleep|shutdown|reboot}" >&2
          exit 2
          ;;
      esac
    '';
  };

  confirm = action: [
    {
      key = "y";
      desc = "Yes";
      cmd = "${lib.getExe powerAction} ${action}";
    }
    {
      key = "n";
      desc = "No";
      cmd = lib.getExe' pkgs.coreutils "true";
    }
  ];
in
{
  options.x.home.desktop.wayland.exitCommand = mkOption {
    type = types.str;
    default = "";
    description = "Command that ends the compositor session.";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.wdisplays
      pkgs.wlr-which-key
    ];

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
              cmd = lib.getExe pkgs.wdisplays;
            }
            {
              key = "p";
              desc = "Power";
              submenu = [
                {
                  key = "o";
                  desc = "Logout";
                  submenu = confirm "logout";
                }
                {
                  key = "s";
                  desc = "Sleep";
                  submenu = confirm "sleep";
                }
                {
                  key = "l";
                  desc = "Lock";
                  cmd = config.x.home.desktop.idle.lockCommand;
                }
                {
                  key = "q";
                  desc = "Shutdown";
                  submenu = confirm "shutdown";
                }
                {
                  key = "r";
                  desc = "Reboot";
                  submenu = confirm "reboot";
                }
              ];
            }
          ];
        };
  };
}
