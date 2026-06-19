{ ... }:
{
  den.aspects.peripherals.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.x.hardware.peripherals;

      deviceColorArgs = lib.concatStringsSep " " (
        lib.filter (s: s != "") (
          lib.imap0 (
            i: cs:
            lib.optionalString (
              cs != [ ]
            ) "--device ${toString i} --mode direct --color ${lib.concatStringsSep "," cs}"
          ) cfg.colors
        )
      );
    in
    {
      options.x.hardware.peripherals = {
        motherboard = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.enum [
              "amd"
              "intel"
            ]
          );
          default = null;
          description = "motherboard vendor for i2c access";
        };

        colors = lib.mkOption {
          type = lib.types.listOf (lib.types.listOf lib.types.str);
          default = [ ];
          example = [
            [
              "006BB6"
              "FFFFFF"
            ]
            [ "F58426" ]
          ];
          description = "per-device rgb colors";
        };
      };

      config = {
        services.hardware.openrgb = {
          enable = true;
          motherboard = cfg.motherboard;
        };

        hardware.i2c.enable = true;
        boot.kernelModules = [ "i2c-dev" ];

        environment.systemPackages = [ pkgs.liquidctl ];
        services.udev.packages = [ pkgs.liquidctl ];

        systemd.services.openrgb-colors = lib.mkIf (deviceColorArgs != "") {
          description = "Apply rgb colors per device";
          after = [ "openrgb.service" ];
          requires = [ "openrgb.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${config.services.hardware.openrgb.package}/bin/openrgb ${deviceColorArgs}";
          };
        };
      };
    };
}
