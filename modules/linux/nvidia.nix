{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.x.hardware.nvidia;
in
{
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
      # renovate: nvidia-production=595.104.02
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "595.104.02";
        sha256_64bit = "sha256-5CHCAuTHn1jDx/MWG75xRU67PYiTb4ggWg4yfNBMWco=";
        sha256_aarch64 = "sha256-PafStmwNMufeDp3VtpTGGCoW+53Gor/mieO1m1pI7gI=";
        openSha256 = "sha256-FWk5ra2yjz8VAxAA8GXrSoeBj/XC1BKvsKsBKR09joE=";
        settingsSha256 = "sha256-4Kxro6tvI5aX4nu2RspgyBsW+Jq3/VYjSAS5UGdzTCU=";
        persistencedSha256 = "sha256-JsMLPqJuZwAtHngsQODMsmgO7F2tVkQ2arc7fYa2bwo=";
      };
      nvidiaPersistenced = true;
      nvidiaSettings = true;
    };

    boot.blacklistedKernelModules = [ "nouveau" ];

    environment.variables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVIDIA_PRESERVE_VIDEO_MEMORY_ALLOCATIONS = "1";
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
