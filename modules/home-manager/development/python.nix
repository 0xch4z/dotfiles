{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.development.enable {
    home = {
      packages = with pkgs; [
        black
        jupyter
        pyright
        #python3
      ];
    };
  };
}
