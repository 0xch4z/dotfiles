_: {
  den.aspects.vsphere.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        govc
      ];
    };
}
