{ inputs, den, ... }:
{
  den.hosts.x86_64-linux.chark0.users.char = { };

  den.aspects.chark0.nixos =
    { pkgs, ... }:
    {
      imports = [ inputs.nixos-facter-modules.nixosModules.facter ];
      facter.reportPath = ./facter.json;

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/f3faac4f-4500-41ef-84df-2dcaaf434207";
        fsType = "ext4";
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/1EBB-7CF1";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
      swapDevices = [ ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.networkmanager.enable = true;

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      services.k3s = {
        enable = true;
        role = "server";
      };

      networking.firewall.allowedTCPPorts = [ 6443 ];

      environment.systemPackages = with pkgs; [ k3s ];

      time.timeZone = "America/New_York";

      system.stateVersion = "24.11";

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
    };
}
