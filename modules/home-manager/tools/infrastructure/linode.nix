{self, pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.tools.infrastructure.enable {
    home = {
      packages = [
        pkgs.linode-cli
        self.inputs.linodectl.packages.${pkgs.system}.default
      ];
    };
  };
}
