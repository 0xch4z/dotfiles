{ self, config, pkgs, ... }:
let
  inherit (self.lib) mkEnableOption mkIf;

  cfg = config.x.home.tools.file;
in {
  options.x.home.tools.file = {
    enable = mkEnableOption "enable file tools";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        fzf
      ];
    };

    programs.yazi = {
      enable = true;
      package = pkgs.unstable.yazi;

      enableFishIntegration = true;

      settings = {
        mgr.show_hidden = true;
      }
      plugins = {
        smart-enter = pkgs.unstable.yaziPlugins.smart-enter;
      };
      keymap = {
        mgr.prepend_keymap = [
          {
            on = "<Enter>";
            run = "plugin --sync smart-enter";
            desc = "enter child directory or open file"
          }
        ];
      };
    };
  };
}
