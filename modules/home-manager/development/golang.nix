{
  pkgs,
  config,
  lib,
  homeDir,
  ...
}:
{
  config = lib.mkIf config.x.home.development.enable {
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
    home.sessionPath = [ "${homeDir}/go/bin" ];

    x.home.development.lsp.servers.go = {
      package = pkgs.gopls;
      args = [ "serve" ];
      opencode = "gopls";
      extensionToLanguage = {
        ".go" = "go";
      };
    };

    programs = {
      go = {
        enable = true;
      };
    };
  };
}
