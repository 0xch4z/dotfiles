_: {
  den.aspects.spotify.homeManager =
    { pkgs, ... }:
    {
      config = {
        home.packages = with pkgs; [
          spotify
        ];
      };
    };
}
