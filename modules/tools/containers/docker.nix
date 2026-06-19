_: {
  den.aspects.docker.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        docker
        docker-buildx
        kind
        #docker-color-output
        #docker-language-server
      ];
    };
}
