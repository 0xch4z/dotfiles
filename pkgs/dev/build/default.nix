{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      #actionlint
      buildpack
      cmake
      devenv
      gnumake
      go-task
    ];
  };
}
