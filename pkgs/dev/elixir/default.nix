{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      elixir
      elixir-ls
      ex_doc
      lexical
      mix2nix
    ];
  };
}
