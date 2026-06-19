_: {
  den.aspects.hetzner.homeManager =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          hcloud
        ];
      };
    };
}
