{ config, lib, pkgs, ... }:
let
  cfg = config.x.hardware.audio;
in {
  options.x.hardware.audio = {
    enable = lib.mkEnableOption "Pipewire audio";
  };

  config = lib.mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    environment.systemPackages = with pkgs; [
      pavucontrol
      pamixer
      playerctl
    ];
  };
}
