{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.development.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home.packages = with pkgs; [
      nixd
    ];
  };
}
