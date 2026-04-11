{ config, lib, pkgs, ... }:
let
  cfg = config.x.hardware.nvidia;
in {
  options.x.hardware.nvidia = {
    enable = lib.mkEnableOption "NVIDIA GPU support";

    open = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use open-source NVIDIA kernel modules";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
      ];
    };

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = cfg.open;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      nvidiaPersistenced = true;
      nvidiaSettings = true;
    };

    boot.blacklistedKernelModules = [ "nouveau" ];

    environment.variables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVIDIA_PRESERVE_VIDEO_MEMORY_ALLOCATIONS = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      NVD_BACKEND = "direct";
    };

    environment.systemPackages = with pkgs; [
      mesa-demos
      vulkan-tools
      nvtopPackages.nvidia
      libva
      libva-utils
    ];
  };
}
