_: {
  den.aspects.equinix.homeManager =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          python313Packages.packet-python
        ];
      };
    };
}
