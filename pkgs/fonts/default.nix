{pkgs, ...}: {
  home = {
    packages = [
      (pkgs.callPackage ./apple-nerdfont.nix {})
    ];
  };
}
