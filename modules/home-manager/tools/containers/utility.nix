{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.tools.containers.enable {
    home.packages = with pkgs; [
      ctop
      (pkgs.callPackage ../../../../pkgs/container/container-linux-config-transpiler.nix {})
    ];
  };
}
