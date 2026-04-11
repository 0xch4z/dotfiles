{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "charbit";
  networking.networkmanager.enable = true;

  users.users.char = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ tree ];
    initialPassword = "changeme!";
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  system.stateVersion = "24.11";
}
