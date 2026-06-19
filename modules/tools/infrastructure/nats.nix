_: {
  den.aspects.nats.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        natscli
        nats-top
        nsc
      ];
    };
}
