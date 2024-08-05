{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      elixir
      elixir-ls
      #lexical
      #mix2nix
    ];
  };
}
