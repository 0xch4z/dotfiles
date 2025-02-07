{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      #actionlint
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
