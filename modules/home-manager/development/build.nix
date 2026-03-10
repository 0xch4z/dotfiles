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
        buildpack
        clang
        (lib.hiPrio gcc)
        cmake
        envsubst
        gnumake
        go-task
        graphviz
        openssl.dev
        pkg-config
        plantuml
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
