{ inputs, den, ... }:
{
  den.hosts.x86_64-linux.charbox.users.ckenney = { };

  den.aspects.charbox = {
    includes = [
      den.aspects.nvidia
      den.aspects.audio
      den.aspects.keyd
      den.aspects.peripherals
      den.aspects.gaming
      den.aspects.nix-ld
      den.aspects.wayland
    ];

    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.nixos-facter-modules.nixosModules.facter ];
        facter.reportPath = ./facter.json;

        fileSystems."/" = {
          device = "/dev/disk/by-uuid/481c06b1-c2f7-4616-9988-24555d683d16";
          fsType = "ext4";
        };
        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/3332-7258";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };
        swapDevices = [ ];

        hardware.bluetooth = {
          enable = true;
          powerOnBoot = true;
        };

        virtualisation.docker.enable = true;

        services.openssh = {
          ports = [ 22 ];
          settings.PasswordAuthentication = false;
        };

        services.greetd = {
          enable = true;
          settings.default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
            user = "greeter";
          };
        };

        boot.loader = {
          systemd-boot.configurationLimit = 10;
          systemd-boot.extraEntries."windows.conf" = ''
            title Windows
            efi /EFI/Microsoft/Boot/bootmgfw.efi
          '';
          timeout = 3;
        };

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

        system.stateVersion = "24.11";

        users.users.ckenney = {
          extraGroups = [
            "audio"
            "docker"
          ];
          packages = with pkgs; [
            ffmpeg
            tree
          ];
          initialPassword = "2300";
        };

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

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
      };
  };
}
