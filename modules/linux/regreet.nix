{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.x.desktop.wayland.greeter;
  wallpaper = pkgs.runCommandLocal "regreet-wallpaper.jpg" { } ''
    cp ${../../assets/philly-dark.jpg} "$out"
  '';

  hyprlandSession = pkgs.writeTextFile {
    name = "hyprland-session";
    destination = "/share/wayland-sessions/hyprland.desktop";
    passthru.providedSessions = [ "hyprland" ];
    text = ''
      [Desktop Entry]
      Name=Hyprland
      Comment=Hyprland Wayland session
      Exec=${pkgs.hyprland}/bin/start-hyprland
      Type=Application
      DesktopNames=Hyprland
    '';
  };

in
{
  options.x.desktop.wayland.greeter.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.x.desktop.wayland.enable;
    defaultText = lib.literalExpression "config.x.desktop.wayland.enable";
    description = "Enable the graphical ReGreet login screen.";
  };

  config = lib.mkIf cfg.enable {
    programs.regreet = {
      enable = true;
      font = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
        size = 16;
      };
      settings = {
        background = {
          path = toString wallpaper;
          fit = "Cover";
        };
        appearance.greeting_msg = "Welcome back";
        GTK = {
          application_prefer_dark_theme = true;
          cursor_blink = false;
        };
        commands = {
          reboot = [
            (lib.getExe' pkgs.systemd "systemctl")
            "reboot"
          ];
          poweroff = [
            (lib.getExe' pkgs.systemd "systemctl")
            "poweroff"
          ];
        };
        widget.clock = {
          format = "%H:%M  %A, %B %-d";
          resolution = "1s";
          label_width = 480;
        };
      };
      extraCss = ''
        window {
          background-color: #061426;
          color: #f0f7ff;
        }

        label {
          color: #f0f7ff;
        }

        frame.background {
          background-color: rgba(6, 20, 38, 0.82);
          border: 1px solid rgba(255, 105, 180, 0.55);
          border-radius: 24px;
          box-shadow: 0 8px 24px rgba(0, 0, 0, 0.55);
          padding: 10px;
        }

        frame.background > border {
          border: none;
        }

        frame.background > label {
          font-size: 28px;
          font-weight: 700;
          padding: 12px 24px;
        }

        entry,
        passwordentry {
          min-height: 48px;
          padding: 0 14px;
          background-color: rgba(10, 32, 58, 0.9);
          color: #f0f7ff;
          border: 2px solid rgba(255, 105, 180, 0.95);
          border-radius: 16px;
          caret-color: #f0f7ff;
        }

        entry:focus,
        passwordentry:focus-within {
          border-color: #006bb6;
          box-shadow: 0 0 0 2px rgba(0, 107, 182, 0.35);
        }

        button {
          min-height: 40px;
          padding: 0 16px;
          background-image: none;
          background-color: rgba(10, 32, 58, 0.9);
          color: #f0f7ff;
          border: 1px solid rgba(0, 107, 182, 0.9);
          border-radius: 12px;
        }

        button:hover {
          background-color: rgba(26, 66, 110, 0.95);
          border-color: #ff69b4;
        }

        button.suggested-action {
          background-image: linear-gradient(45deg, #ff69b4, #006bb6);
          border-color: #ff69b4;
          color: #ffffff;
          font-weight: 700;
        }

        button.destructive-action {
          border-color: rgba(255, 80, 110, 0.9);
        }

        popover contents {
          background-color: rgba(6, 20, 38, 0.97);
          color: #f0f7ff;
          border: 1px solid rgba(255, 105, 180, 0.55);
          border-radius: 12px;
        }
      '';
    };

    services.displayManager.sessionPackages = [ hyprlandSession ];

    services.greetd = {
      enable = true;
      useTextGreeter = false;
    };
  };
}
