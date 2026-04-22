{ lib, ... }: {
  imports = [
    ./audio.nix
    ./keyd.nix
    ./nix-ld.nix
    ./nvidia.nix
    ./wayland.nix
  ];

  programs.fish.enable = true;

  time.timeZone = lib.mkDefault "America/New_York";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  services.openssh.enable = lib.mkDefault true;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
