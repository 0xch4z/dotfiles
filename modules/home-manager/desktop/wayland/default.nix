{
  self,
  config,
  lib,
  ...
}:
let
  inherit (self.lib) types mkOption;
in
{
  options.x.home.desktop.wayland = {
    enable = mkOption {
      type = types.bool;
      readOnly = true;
      default = lib.elem config.x.home.desktop.backend [
        "hyprland"
        "niri"
      ];
      description = "Whether the active desktop backend is a Wayland compositor.";
    };

    dpmsCommand = {
      off = mkOption {
        type = types.str;
        default = "";
        description = "Command that blanks the outputs.";
      };

      on = mkOption {
        type = types.str;
        default = "";
        description = "Command that wakes the outputs.";
      };
    };
  };

  imports = [
    ./cursor.nix
    ./idle.nix
    ./wallpaper.nix
    ./which-key.nix
  ];
}
