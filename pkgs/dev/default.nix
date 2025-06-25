{pkgs, ...}: {
  imports = [
    ./build
    ./data
    ./elixir
    ./golang
    ./javascript
    ./lua
    ./nix
    ./protobuf
    ./python
    ./rust
    ./sql
    #./version-control/git
  ];

  home.packages = with pkgs; [
    buildkite-agent
    buildkite-cli
    minio-client
    s5cmd
    slint-lsp
    vscode # :(

    pyright
  ];
}
