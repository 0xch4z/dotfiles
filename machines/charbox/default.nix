{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  x.hardware.nvidia.enable = true;
  x.hardware.audio.enable = true;
  x.hardware.keyd.enable = true;
  x.hardware.peripherals.enable = true;
  x.hardware.peripherals.motherboard = "amd";
  x.hardware.peripherals.colors =
    let
      ram = builtins.genList (i: if (i / 2) * 2 == i then "006BB6" else "FFFFFF") 12;
    in
    [
      ram
      ram
      [ "F58426" ]
      [ "006BB6" ]
      [ "F58426" ]
    ];
  x.programs.nix-ld.enable = true;
  x.programs.gaming.enable = true;
  x.desktop.wayland.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

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
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
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
  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles.profiles.charbox-lan = {
    connection = {
      id = "charbox-lan";
      type = "ethernet";
      interface-name = "enp12s0";
      autoconnect = true;
    };
    ipv4 = {
      method = "manual";
      address1 = "192.168.100.69/24,192.168.100.1";
      dns = "8.8.8.8;";
    };
    ipv6.method = "disabled";
  };

  users.users.ckenney = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "audio"
      "docker"
      "networkmanager"
    ];
    packages = with pkgs; [
      ffmpeg
      tree
    ];
    initialPassword = "2300";
  };

  system.stateVersion = "24.11";
}
