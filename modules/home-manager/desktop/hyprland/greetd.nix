{ config, pkgs, lib, ... }:
let
  inherit (lib) literalExpression mkIf mkOption types;

  cfg = config.x.home.desktop.hyprland;
  hyprlandEnabled = config.x.home.desktop.backend == "hyprland";
in {

  options.x.home.desktop.hyprland.greetdIntegration = {
    enable = mkOption {
      type = types.bool;
      default = hyprlandEnabled;
      defaultText = literalExpression "config.desktop.hyprland.enable";
      description = "enable hyprland greetd integration";
    };
  };

  config = mkIf cfg.greetdIntegration {
    # TODO: figure out how to do this with hm
    # services.greetd = {
    #   enable = true;

    #   vt = 2;
    #   settings = {
    #     default_session = {
    #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
    #       user = "greeter";
    #     };
    #   };
    # };
  };
}

