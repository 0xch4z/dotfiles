_: {
  den.aspects.cloudflare.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        cfssl
        cfspeedtest
      ];
    };
}
