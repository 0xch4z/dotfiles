{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.tools.infrastructure.hetzner.enable {
    home = {
      packages = with pkgs; [
        hcloud
      ];
    };
  };
}
