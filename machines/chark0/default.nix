{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "chark0";
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  users.users.char = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
  };

  services.k3s = {
    enable = true;
    role = "server";
  };

  networking.firewall.allowedTCPPorts = [ 6443 ];

  environment.systemPackages = with pkgs; [ k3s ];

  time.timeZone = "America/New_York";

  system.stateVersion = "24.11";
}
