{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.x.home.development.enable {
    x.home.development.lsp.servers.elixir = {
      package = pkgs.elixir-ls;
      exe = "elixir-ls";
      opencode = "elixir-ls";
      extensionToLanguage = {
        ".ex" = "elixir";
        ".exs" = "elixir";
      };
    };

    home.packages = with pkgs; [
      elixir
      elixir-ls
      #lexical
      #mix2nix
    ];
  };
}
