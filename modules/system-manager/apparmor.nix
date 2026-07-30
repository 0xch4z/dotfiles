{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.x.system.apparmor.bubblewrap;

  profileText = ''
    abi <abi/4.0>,

    include <tunables/global>

    @{NIX_BWRAP}=${lib.concatStringsSep " " cfg.paths}

    profile nix-bwrap @{NIX_BWRAP} flags=(unconfined) {
      allow userns create,

      # Site-specific additions and overrides.
      include if exists <local/nix-bwrap>
    }
  '';

  loadProfile = pkgs.writeShellScript "load-nix-bwrap-apparmor" ''
    set -eu

    for parser in /usr/sbin/apparmor_parser /sbin/apparmor_parser; do
      if [ -x "$parser" ]; then
        exec "$parser" --replace /etc/apparmor.d/nix-bwrap
      fi
    done

    echo "apparmor_parser not found" >&2
    exit 1
  '';
in
{
  options.x.system.apparmor.bubblewrap = {
    enable = lib.mkEnableOption "AppArmor profile allowing bubblewrap to create unprivileged user namespaces";

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/nix/store/*-bubblewrap-*/bin/bwrap"
        "/home/*/.nix-profile/bin/bwrap"
        "/etc/profiles/per-user/*/bin/bwrap"
        "/run/current-system/sw/bin/bwrap"
        "/run/system-manager/sw/bin/bwrap"
        "/usr/bin/bwrap"
      ];
      description = "Executable paths that should attach to the nix-bwrap AppArmor profile.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."apparmor.d/nix-bwrap".text = profileText;

    systemd.tmpfiles.rules = [
      "d /etc/apparmor.d/local 0755 root root -"
    ];

    systemd.services.nix-bwrap-apparmor = {
      enable = true;
      description = "Load AppArmor profile for Nix bubblewrap";
      after = [ "apparmor.service" ];
      wants = [ "apparmor.service" ];
      wantedBy = [ "system-manager.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = loadProfile;
        ExecReload = loadProfile;
        Environment = "NIX_BWRAP_APPARMOR_PROFILE_HASH=${builtins.hashString "sha256" profileText}";
      };
    };
  };
}
