{
  lib,
  inputs,
  nixpkgs,
  pkgs,
  ...
}: {
  ids.uids.nixbld = 300;

  # environment.shells = [pkgs.fish];
  programs.fish.enable = true;

  fonts = {
    packages = [ (pkgs.callPackage ../../pkgs/fonts/apple-nerdfont.nix {}) ];
  };

  users.users.char = {
    name = "char";
    home = "/Users/char";
    shell = pkgs.fish;
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

  security.pam.services.sudo_local.touchIdAuth = true;


  nix = {
    nixPath = lib.mkForce [
      "nixpkgs=${nixpkgs}"
    ];
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings = {
      trusted-users = ["root" "char"];
    };
  };

  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
