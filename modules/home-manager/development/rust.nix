{ pkgs, config, lib, ... }: {
  config = lib.mkIf config.x.home.development.enable {
    home = {
      packages = with pkgs;
        [
          #rust-bin.beta.latest.default
          rustup
        ];
      sessionPath = [ "${config.xdg.configHome}/cargo/bin" ];
      sessionVariables = { CARGO_HOME = "${config.xdg.configHome}/cargo"; };
    };
  };
}
