{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
    };
  };

  services.greetd = {
    enable = true;

    vt = 2;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  services.xserver = {
    videoDrivers = ["nvidia"];
    # displayManager = {
    #   sddm.enable = true;
    # };
    # desktopManager.gnome = {
    #   enable = true;
    #   extraGSettingsOverrides = ''
    #   [com.ubuntu.login-screen]
    #   background-repeat='no-repeat'
    #   background-size='cover'
    #   background-color='#000000'
    #   background-picture-uri=\'\'
    #   '';
    # };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "charbox"; # Define your hostname.

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.ckenney = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    initialPassword = "2300";
  };

  # sound
  services.pipewire = { enable = true; pulse.enable = true; };

  environment.systemPackages = with pkgs; [
    glxinfo
    vulkan-tools
    nvtopPackages.full

    libva
    libva-utils

    wget
    alacritty

    wofi
    mako
    wl-clipboard
    grim
    slurp
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management can cause sleep/suspend to fail.
    powerManagement.enable = false;

    # open-source drivers
    open = true;

    # latest stable
    #package = config.boot.kernelPackages.nvidiaPackages.stable;
    # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #   version = "570.86.16"; # use new 570 drivers
    #   sha256_64bit = "sha256-RWPqS7ZUJH9JEAWlfHLGdqrNlavhaR1xMyzs8lJhy9U=";
    #   openSha256 = "sha256-DuVNA63+pJ8IB7Tw2gM4HbwlOh1bcDg2AN2mbEU9VPE=";
    #   settingsSha256 = "sha256-9rtqh64TyhDF5fFAYiWl3oDHzKJqyOW3abpcf2iNRT8=";
    #   usePersistenced = false;
    # };
    #forceFullCompositionPipeline = true;
    nvidiaPersistenced = true; # keeps driver persistent, perf
    nvidiaSettings = true;
  };

  # disable default driver in favor of nvidia
  boot.blacklistedKernelModules = [ "nouveau" ];

  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia";

    # NVIDIA in Wayland
    WLR_NO_HARDWARE_CURSORS = "1";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";


    # Tell electron apps to use wayland
    NIXOS_OZONE_WL = "1";

    # Firefox HW acceleration
    MOZ_DISABLE_RDD_SANDBOX = "1";
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

