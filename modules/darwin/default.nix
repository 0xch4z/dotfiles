{ lib, nixpkgs, pkgs, ... }: {
  programs.fish.enable = true;

  fonts = {
    packages = [ (pkgs.callPackage ../../pkgs/fonts/apple-nerdfont.nix {}) ];
  };

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 1.0;
        tilesize = lib.mkDefault 50;
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
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 10;
        KeyRepeat = 1;
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "Automatic";
        AppleFontSmoothing = 0;
      };
    };

    stateVersion = 4;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  nix = {
    nixPath = lib.mkForce [ "nixpkgs=${nixpkgs}" ];
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
