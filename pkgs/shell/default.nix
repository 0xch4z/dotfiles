{pkgs, ...}: {
  imports = [
    ./fish
  ];
  home = {
    packages = with pkgs; [
      bashInteractive
      dash
      elvish
      shellcheck
      shfmt
    ];
  };
}
