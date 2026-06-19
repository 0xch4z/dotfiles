_: {
  den.aspects.caffeine.homeManager =
    { pkgs, ... }:
    {
      config = {
        home.packages = with pkgs; [
          #x.caffeine-bin
        ];
      };
    };

  den.aspects.gitify.homeManager =
    { pkgs, ... }:
    {
      config = {
        home.packages = with pkgs; [
          gitify
        ];
      };
    };
}
