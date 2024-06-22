{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      linodecli
    ];
  };
}
