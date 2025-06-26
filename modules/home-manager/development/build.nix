{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.development.enable {
    home.packages = with pkgs; [
      actionlint
      buildpack
      devcontainer
      devpod
      cmake
      devenv
      gnumake
      go-task
      graphviz
      plantuml
    ];
  };
}
