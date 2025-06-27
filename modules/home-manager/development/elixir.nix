{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.development.enable {
    home.packages = with pkgs; [
      elixir
      elixir-ls
      #lexical
      #mix2nix
    ];
  };
}
