_: {
  den.aspects.dev-data.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # protobuf
        # buf # buf is broken on latest nixpkgs
        protolint

        # csv
        csvq

        # diffing
        delta
        diffutils

        # json
        jq
        jsonfmt

        # yaml
        yamlfmt
        yamllint
        yaml-language-server
        yq-go

        # sql
        sql-formatter
        sqlite
      ];
    };
}
