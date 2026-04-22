{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.tools.infrastructure.nats.enable {
    home.packages = with pkgs; [
      natscli
      nats-top
      nsc
    ];
  };
}
