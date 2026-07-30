{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.x.system.docker;
in
{
  options.x.system.docker = {
    enable = lib.mkEnableOption "Docker daemon";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Users to add to the docker group.";
    };

    daemon.settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {
        log-driver = "json-file";
        log-opts = {
          max-size = "10m";
          max-file = "3";
        };
        storage-driver = "overlay2";
      };
      description = "Docker daemon.json settings.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      docker
      docker-buildx
      docker-compose
    ];

    environment.etc."docker/daemon.json".text = builtins.toJSON cfg.daemon.settings;

    users.groups.docker.members = cfg.users;

    systemd.services.docker = {
      enable = true;
      description = "Docker Application Container Engine";
      documentation = [ "https://docs.docker.com" ];
      path = [
        pkgs.apparmor-parser
      ];
      after = [
        "network-online.target"
        "userborn.service"
        "docker.socket"
      ];
      wants = [ "network-online.target" ];
      requires = [
        "userborn.service"
        "docker.socket"
      ];
      wantedBy = [ "system-manager.target" ];
      serviceConfig = {
        Type = "notify";
        ExecStart = "${pkgs.docker}/bin/dockerd --host=fd://";
        ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
        TimeoutStartSec = 0;
        RestartSec = 2;
        Restart = "always";
        StartLimitBurst = 3;
        StartLimitInterval = "60s";
        LimitNOFILE = 1048576;
        LimitNPROC = "infinity";
        LimitCORE = "infinity";
        TasksMax = "infinity";
        Delegate = "yes";
        KillMode = "process";
        OOMScoreAdjust = -500;
      };
    };

    systemd.sockets.docker = {
      enable = true;
      description = "Docker Socket for the API";
      after = [ "userborn.service" ];
      requires = [ "userborn.service" ];
      wantedBy = [ "system-manager.target" ];
      socketConfig = {
        ListenStream = "/run/docker.sock";
        SocketMode = "0660";
        SocketUser = "root";
        SocketGroup = "docker";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/docker 0710 root root -"
      "d /run/docker 0755 root root -"
      "d /etc/docker 0755 root root -"
    ];
  };
}
