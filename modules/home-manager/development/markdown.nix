{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.x.home.development.enable {
    home.packages = with pkgs; [
      marksman
    ];

    x.home.development.lsp.servers.markdown = {
      package = pkgs.marksman;
      args = [ "server" ];
      extensionToLanguage = {
        ".md" = "markdown";
        ".markdown" = "markdown";
        ".mdx" = "markdown";
      };
    };
  };
}
