_: {
  den.aspects.containers-utility.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ctop
        (pkgs.callPackage ../../../pkgs/container/container-linux-config-transpiler.nix { })
      ];
    };
}
