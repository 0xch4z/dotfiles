{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.tools.infrastructure.packer.enable {
    home.packages = with pkgs; [
      packer
    ];
  };
}
