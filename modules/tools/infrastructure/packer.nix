_: {
  den.aspects.packer.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        packer
      ];
    };
}
