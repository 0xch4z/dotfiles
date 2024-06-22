{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      actionlint
      buildpack
      cmake
      gnumake
      go-task
    ];
  };
}
