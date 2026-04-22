{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.tools.infrastructure.cloudflare.enable {
    home.packages = with pkgs; [
      cfssl
      cfspeedtest
    ];
  };
}
