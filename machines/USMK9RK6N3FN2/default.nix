{
  lib,
  inputs,
  nixpkgs,
  pkgs,
  ...
}: {
  environment.shells = [pkgs.fish pkgs.bashInteractive];
  programs.bash.enable = true;
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
      coreutils
      ffmpeg
      fswatch
      fzf
      gnupg
      home-manager
      kitty
      openssl
      mods
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.ckenney = {
      imports = [
        ../../profiles/work-macos
        ../../roles/work-macos
      ];
    };
  };

  users.users.ckenney = {
    name = "ckenney";
    home = "/Users/ckenney";
    shell = "fish";
  };

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 1.0;
        tilesize = 75;
        static-only = false;
        showhidden = false;
        show-recents = false;
        show-process-indicators = true;
        orientation = "bottom";
        mru-spaces = false;
      };

      NSGlobalDomain = {
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.swipescrolldirection" = false;
        # Allow key repeat
        ApplePressAndHoldEnabled = false;
        # Delay before repeating keystrokes (ms, 100 per sec.)
        InitialKeyRepeat = 10;
        # Delay between repeated keystrokes upon holding a key
        KeyRepeat = 1;
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Automatic";
        # Makes fonts look better. See https://tonsky.me/blog/monitors.
        AppleFontSmoothing = 0;
      };
    };
  };

  security.pam.enableSudoTouchIdAuth = true;

  nix = {
    nixPath = lib.mkForce [
      "nixpkgs=${nixpkgs}"
    ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
