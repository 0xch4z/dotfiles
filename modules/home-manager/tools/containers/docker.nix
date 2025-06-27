{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.tools.containers.enable {
    home.packages = with pkgs; [
      docker
      docker-buildx
      #docker-color-output
      #docker-language-server
    ];
  };
}
