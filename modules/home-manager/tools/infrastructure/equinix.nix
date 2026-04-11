{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.tools.infrastructure.equinix.enable {
    home = {
      packages = with pkgs; [
        python313Packages.packet-python
      ];
    };
  };
}
