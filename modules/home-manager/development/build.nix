{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.x.home.development.enable {
    home.packages =
      with pkgs;
      [
        actionlint
        autotools-language-server
        x.actions-languageserver
        buildpack
        clang
        cmake
        codespell
        (lib.hiPrio gcc)
        editorconfig-core-c
        envsubst
        gnumake
        go-task
        graphviz
        openssl.dev
        pkg-config
        plantuml
        tree-sitter
        gemini-cli
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        dbus.dev
      ];

    home.sessionVariables = {
      PKG_CONFIG_PATH =
        lib.makeSearchPath "lib/pkgconfig" [
          pkgs.openssl.dev
        ]
        + lib.optionalString pkgs.stdenv.hostPlatform.isLinux ":${
          lib.makeSearchPath "lib/pkgconfig" [ pkgs.dbus.dev ]
        }";
    };
  };
}
