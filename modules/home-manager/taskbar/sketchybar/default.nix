{pkgs, config, lib, homeDir, ...}:
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

    xdg.configFile."sketchybar/sketchybarrc" = {
      text =
        ''
          #! ${pkgs.lua5_4_compat}/bin/lua
          package.cpath = package.cpath
            .. ";${pkgs.lua54Packages.cjson}/lib/lua/5.4/?.so"
            .. ";${pkgs.lua54Packages.luaposix}/lib/lua/5.4/?.so"
            .. ";${pkgs.x.sbarlua}/lib/?.so"

          package.path = package.path
            .. ";${config.xdg.configHome}/sketchybar/?/init.lua"
            .. ";${config.xdg.configHome}/sketchybar/config/?.lua"

          require("config")
        '';
      executable = true;
    };

    xdg.configFile."sketchybar/nix_bridge.lua".text = ''
      return {
        cmds = {
          is-macbook-display-only = "${pkgs.x.is-macbook-display-only}/bin/is-macbook-display-only"
        }
      }
    '';

    xdg.configFile.sketchybar = {
      enable = true;
      recursive = true;
      source = config.lib.file.mkOutOfStoreSymlink
        "${homeDir}/.dotfiles/modules/home-manager/taskbar/sketchybar/config";
      target = "sketchybar/config";
    };
  };
}
