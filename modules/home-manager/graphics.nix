{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.x.home.graphics.nixGL;
in
{
  options.x.home.graphics.wrapPackage = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    internal = true;
    default =
      package:
      if cfg.enable && pkgs.stdenv.hostPlatform.isLinux then config.lib.nixGL.wrap package else package;
    description = "Wrap a graphical package with NixGL when this home profile requires it.";
  };

  options.x.home.graphics.nixGL = {
    enable = lib.mkEnableOption "NixGL wrapping for graphical programs on non-NixOS Linux";

    defaultWrapper = lib.mkOption {
      type = lib.types.enum [
        "mesa"
        "mesaPrime"
        "nvidia"
        "nvidiaPrime"
      ];
      default = "mesa";
      description = "Default NixGL wrapper used for graphical packages.";
    };

    installScripts = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "mesa"
          "mesaPrime"
          "nvidia"
          "nvidiaPrime"
        ]
      );
      default = [ "mesa" ];
      description = "NixGL wrapper scripts to install into the user environment.";
    };

    vulkan.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Vulkan support in NixGL wrappers.";
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isLinux) {
    targets.genericLinux.enable = lib.mkDefault true;

    targets.genericLinux.nixGL = {
      packages = self.inputs.nixgl.packages;
      defaultWrapper = cfg.defaultWrapper;
      inherit (cfg) installScripts;
      vulkan.enable = cfg.vulkan.enable;
    };
  };
}
