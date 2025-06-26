{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    libpng
    libjpeg
    openssl
    bzip2
    xz
    ncurses
    readline
    sqlite
    libffi
    expat
    libxml2
    libxslt
    libGL
    mesa
    glib
    gtk3
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXi
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXinerama
    xorg.libXxf86vm
  ];

  home-manager.users.ckenney = {
    home.sessionVariables = {
      LD_LIBRARY_PATH = "${pkgs.cudatoolkit}/lib64:/run/current-system/sw/share/nix-ld/lib";
    };
  };

  # themeing
  qt5.platformTheme = "qt5ct";

  # Additional environment variables
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    NIXOS_OZONE_WL = "1";
  };

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
  };
 
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "charbox"; # Define your hostname.

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.ckenney = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      ffmpeg
      tree
    ];
    initialPassword = "2300";
  };

  # sound
  hardware.pulseaudio.enable = false; # in favor of pipewire
  security.rtkit.enable = true; # allows pipewire to request realtime scheduling. reduces audio latency.
  services.pipewire = {
    enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
  };

  environment.systemPackages = with pkgs; [
    glxinfo
    vulkan-tools
    nvtopPackages.full

    libva
    libva-utils

    wget
    alacritty

    # sound
    pavucontrol
    pamixer
    playerctl

    rofi
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
    open = false;

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
    CUDA_PATH = "${pkgs.cudatoolkit}";
    CUDA_ROOT = "${pkgs.cudatoolkit}";

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

  system.stateVersion = "24.11";
}
