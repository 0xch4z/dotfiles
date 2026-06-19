_: {
  den.aspects.python.homeManager =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          black
          #jupyter
          pyright
          pipenv
          #python3
          uv
        ];
      };
    };
}
