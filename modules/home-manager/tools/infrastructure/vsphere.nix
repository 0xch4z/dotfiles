{config, pkgs, lib, ...}: {
  config = lib.mkIf config.x.home.tools.infrastructure.vsphere.enable {
    home.packages = with pkgs; [
      govc
    ];
  };
}
