{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.development.enable {
    home.packages = with pkgs; [
      # protobuf
      buf
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
      nodePackages.sql-formatter
      sqlite
    ];
  };
}
