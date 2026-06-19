{ inputs, den, ... }:
{
  den.hosts.x86_64-linux.charbit.users.char = { };

  den.aspects.charbit.nixos =
    { pkgs, ... }:
    {
      imports = [ inputs.nixos-facter-modules.nixosModules.facter ];
      facter.reportPath = ./facter.json;

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/e03601eb-ef0d-47e8-afe7-97f377d54247";
        fsType = "ext4";
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/A67E-CD31";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };
      swapDevices = [
        { device = "/dev/disk/by-uuid/a3e89f67-e726-4d0b-8887-818f2df0576c"; }
      ];

      networking.networkmanager.enable = true;

      users.users.char = {
        extraGroups = [ "wheel" ];
        packages = [ pkgs.tree ];
        initialPassword = "changeme!";
      };

      environment.systemPackages = with pkgs; [
        vim
        wget
      ];

      system.stateVersion = "24.11";

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
    };
}
