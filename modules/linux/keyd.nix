{ config, lib, ... }:
let
  cfg = config.x.hardware.keyd;
in {
  options.x.hardware.keyd = {
    enable = lib.mkEnableOption "keyd keyboard remapping (Mac-style bindings)";
  };

  config = lib.mkIf cfg.enable {
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings = {
          alt = {
            "left" = "C-left";
            "right" = "C-right";
          };
          meta = {
            "a" = "C-a";
            "c" = "C-c";
            "f" = "C-f";
            "r" = "C-r";
            "v" = "C-v";
            "x" = "C-x";
            "z" = "C-z";
            "left" = "home";
            "right" = "end";
            "shift-left" = "S-home";
            "shift-right" = "S-end";
            "delete" = "S-home delete";
          };
        };
      };
    };
  };
}
