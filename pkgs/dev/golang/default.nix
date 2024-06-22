{config, pkgs, ...}: {
  home = {
    packages = with pkgs; [
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
    sessionPath = [
      "$HOME/${config.programs.go.goPath}/bin"
    ];
  };

  programs = {
    go = {
      enable = true;
      goPath = "go";
    };
  };
}
