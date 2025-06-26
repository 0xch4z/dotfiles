{ self, ... }:
let
  inherit (self.lib) mkEnabledOption;
in {
  options.x.home.development = {
    enable = mkEnabledOption "enable development";
  };

  imports = [
    ./build.nix
    ./data.nix
    ./elixir.nix
    ./git.nix
    ./golang.nix
    ./javascript.nix
    ./lua.nix
    ./nix.nix
    ./python.nix
    ./rust.nix
    ./shell.nix
  ];
}
