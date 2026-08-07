{
  self,
  config,
  lib,
  ...
}:
let
  cfg = config.x.system.nix;
in
{
  options.x.system.nix = {
    enable = lib.mkEnableOption "Nix daemon custom settings";

    trustedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Users trusted by the Nix daemon.";
    };

    extraSubstituters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = self.constants.nixCaches.substituters;
      description = "Extra binary caches to add to the Nix daemon.";
    };

    extraTrustedPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = self.constants.nixCaches.trustedPublicKeys;
      description = "Trusted public keys for extra binary caches.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."nix/nix.custom.conf" = {
      replaceExisting = true;
      text = ''
        # Managed by system-manager. This file is included by Determinate Nix's
        # generated /etc/nix/nix.conf.
        trusted-users = ${lib.concatStringsSep " " ([ "root" ] ++ cfg.trustedUsers)}
        extra-substituters = ${lib.concatStringsSep " " cfg.extraSubstituters}
        extra-trusted-substituters = ${lib.concatStringsSep " " cfg.extraSubstituters}
        extra-trusted-public-keys = ${lib.concatStringsSep " " cfg.extraTrustedPublicKeys}
      '';
    };
  };
}
