{ pkgs, config, lib, ... }: {
  config = lib.mkIf config.x.home.development.enable {
    home.packages = with pkgs; [
      actionlint
      buildpack
      cmake
      envsubst
      gnumake
      go-task
      graphviz
      plantuml
      gemini-cli
    ];
  };
}
