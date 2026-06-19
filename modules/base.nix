{
  den,
  inputs,
  lib,
  ...
}:
{
  den.default.includes = [
    den.batteries.define-user
    den.batteries.hostname
  ];

  den.schema.user.includes = [
    (den.lib.policy.mkPolicy "host-user-aspect" (
      { host, user, ... }:
      lib.optional (
        (den.aspects ? ${host.name}) && (den.aspects.${host.name} ? ${user.name})
      ) (den.lib.policy.include den.aspects.${host.name}.${user.name})
    ))
  ];

  den.default.nixos =
    {
      host,
      lib,
      ...
    }:
    {
      nixpkgs.hostPlatform = host.system;
      nixpkgs.config = {
        allowUnfree = true;
        allowBroken = true;
        allowUnsupportedSystem = true;
      };
      nixpkgs.overlays = [
        (import ../overlays.nix {
          inherit inputs;
          lib = inputs.nixpkgs.lib;
        })
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

      nix.extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

  den.default.homeManager =
    {
      host,
      user,
      config,
      ...
    }:
    {
      home.sessionVariables = {
        NIX_SYSTEM = "1";
        NIX_VARIANT = host.class;
        NIX_USERHOST = "${user.name}@${host.name}";
      };

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 3d --keep 3";
        flake = "${config.home.homeDirectory}/.dotfiles";
      };
    };
}
