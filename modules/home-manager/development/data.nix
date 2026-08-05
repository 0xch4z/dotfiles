{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.x.home.development.enable {
    x.home.development.lsp.servers.yaml = {
      package = pkgs.yaml-language-server;
      args = [ "--stdio" ];
      opencode = "yaml-ls";
      extensionToLanguage = {
        ".yaml" = "yaml";
        ".yml" = "yaml";
      };
    };

    home.packages = with pkgs; [
      # protobuf
      # buf # buf is broken on latest nixpkgs
      protolint

      # csv
      csvq

      # diffing
      delta
      diffutils

      # json
      jq
      jsonfmt

      # yaml
      yamlfmt
      yamllint
      yaml-language-server
      yq-go

      # sql
      sql-formatter
      sqlite
    ];
  };
}
