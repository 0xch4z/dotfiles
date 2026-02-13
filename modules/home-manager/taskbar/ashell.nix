{ config, lib, pkgs, ... }:
let cfg = config.x.home.taskbar.ashell;
in {
  options.x.home.taskbar.ashell = {
    enable = lib.mkEnableOption "Enable ashell home-manager module.";
  };

  config = lib.mkIf cfg.enable {
    programs.ashell = {
      enable = true;
      settings = { };
    };
  };
}
