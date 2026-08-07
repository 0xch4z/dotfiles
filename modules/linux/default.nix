{ self, lib, ... }:
{
  imports = [
    ./audio.nix
    ./gaming.nix
    ./keyd.nix
    ./nix-ld.nix
    ./nvidia.nix
    ./peripherals.nix
    ./regreet.nix
    ./wayland.nix
  ];

  programs.fish.enable = true;

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  time.timeZone = lib.mkDefault "America/New_York";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  services.openssh.enable = lib.mkDefault true;

  nix = {
    settings = {
      inherit (self.constants.nixCaches) substituters;
      trusted-substituters = self.constants.nixCaches.substituters;
      trusted-public-keys = self.constants.nixCaches.trustedPublicKeys;
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
