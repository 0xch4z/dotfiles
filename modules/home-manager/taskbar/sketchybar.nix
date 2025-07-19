{self, config, pkgs, lib, ...}:
let
  cfg = config.x.home.taskbar.sketchybar;
in {
  options.x.home.taskbar.sketchybar = {
    enable = lib.mkEnableOption "enable sketchybar";

    autoHideSystemMenubar = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      sketchybar
    ];
  };
}
