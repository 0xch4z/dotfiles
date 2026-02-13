{self, config, pkgs, lib}:
let
  cfg = config.x.home.development.nix-ld;
in {
  options.x.home.development.nix-ld = {
    enable = mkOption {
      type = pkgs.types.boolean;
      default = config.x.home.development.enable;
    };

    extraLibraries = mkOption {
      default = [];
    };
  };


  config = lib.mkIf cfg.enable {
    programs.nix-ld = {
      enable = cfg.enable;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        libcurl
        libzstd
        libpng
        libjpeg
        openssl
        bzip2
        xz
        ncurses
        readline
        sqlite
        libffi
        expat
        libxml2
        libxslt
        libGL
      ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [

      ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [

      ] ++ extraLibraries;
    };
  ;
}
