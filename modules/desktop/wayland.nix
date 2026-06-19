{ ... }:
{
  den.aspects.wayland.nixos =
    {
      lib,
      pkgs,
      ...
    }:
    {
      qt.platformTheme = lib.mkDefault "qt5ct";

      environment.sessionVariables = {
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_QPA_PLATFORMTHEME = "qt5ct";
        NIXOS_OZONE_WL = "1";
      };

      environment.variables = {
        XDG_SESSION_TYPE = "wayland";
        MOZ_ENABLE_WAYLAND = "1";
        MOZ_DISABLE_RDD_SANDBOX = "1";
      };

      environment.pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];

      environment.systemPackages = with pkgs; [
        wl-clipboard
        libnotify
        grim
        slurp
      ];
    };
}
