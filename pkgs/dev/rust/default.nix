{
  config,
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      #rust-bin.beta.latest.default
      cargo
      rustc
      rust-analyzer
    ];
    sessionPath = [
      "${config.xdg.configHome}/cargo/bin"
    ];
    sessionVariables = {
      CARGO_HOME = "${config.xdg.configHome}/cargo";
    };
  };
}
