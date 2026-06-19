_: {
  den.aspects.colima.homeManager =
    { config, pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          colima
        ];

        sessionVariables = {
          LIMA_HOME = "${config.xdg.configHome}/lima";
          DOCKER_HOST = "unix://$HOME/.colima/default/docker.sock";
        };
      };
    };
}
