{pkgs, ...}: {
  imports = [
    ./build
    ./data
    ./elixir
    ./golang
    ./javascript
    ./lua
    ./protobuf
    ./python
    ./rust
    ./sql
    #./version-control/git
  ];

  home.packages = with pkgs; [
    slint-lsp
    vscode # :(
  ];
}
