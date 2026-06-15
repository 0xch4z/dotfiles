{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.x.home.development.enable {
    home = {
      packages = with pkgs; [
        (rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
          ];
        })

        (lib.lowPrio rustup)
      ];
      sessionPath = [ "${config.xdg.configHome}/cargo/bin" ];
      sessionVariables = {
        CARGO_HOME = "${config.xdg.configHome}/cargo";
      };
    };
  };
}
