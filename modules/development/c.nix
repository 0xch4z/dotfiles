_: {
  den.aspects.dev-c.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        clang-tools
      ];
    };
}
