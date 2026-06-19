_: {
  den.aspects.golang.homeManager =
    {
      pkgs,
      config,
      ...
    }:
    {
      home.packages = with pkgs; [
        delve
        gofumpt
        gopls
        gops
        gore
        gotest
        gotestsum
        gotools
        gox
        golangci-lint
        golangci-lint-langserver
        protoc-gen-go
        protoc-gen-go-grpc
      ];
      home.sessionPath = [ "${config.home.homeDirectory}/go/bin" ];

      programs = {
        go = {
          enable = true;
        };
      };
    };
}
