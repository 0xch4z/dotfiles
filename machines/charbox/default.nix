{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  x.hardware.nvidia.enable = true;
  x.hardware.audio.enable = true;
  x.hardware.keyd.enable = true;
  x.programs.nix-ld.enable = true;
  x.desktop.wayland.enable = true;

  virtualisation.docker.enable = true;

  services.openssh = {
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  boot.loader = {
    systemd-boot.configurationLimit = 10;
    systemd-boot.extraEntries = {
      "windows.conf" = ''
        title Windows
        efi /EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };
    timeout = 3;
  };

  networking.hostName = "charbox";
  networking.nameservers = [ "8.8.8.8" ];
  networking.defaultGateway = {
    address = "192.168.100.1";
    interface = "enp12s0";
  };
  networking.interfaces.enp12s0.ipv4.addresses = [
    {
      address = "192.168.100.69";
      prefixLength = 24;
    }
  ];

  users.users.ckenney = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "audio"
      "docker"
    ];
    packages = with pkgs; [
      ffmpeg
      tree
    ];
    initialPassword = "2300";
  };

  system.stateVersion = "24.11";
}
