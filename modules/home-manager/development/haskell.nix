{
  pkgs,
  config,
  lib,
  ...
}:
let
  hls = pkgs.haskell-language-server;
in
{
  config = lib.mkIf config.x.home.development.enable {
    home.packages = with pkgs; [
      cabal-install
      ghc
      hls
    ];

    x.home.development.lsp.servers.haskell = {
      package = hls;
      exe = "haskell-language-server-wrapper";
      args = [ "--lsp" ];
      extensionToLanguage = {
        ".hs" = "haskell";
        ".lhs" = "haskell";
      };
    };
  };
}
