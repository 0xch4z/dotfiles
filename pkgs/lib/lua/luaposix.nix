{ pkgs, ... }:
let
  lua = pkgs.lua5_4_compat;
in pkgs.stdenv.mkDerivation {
  pname = "luaposix";
  version = "0.1";

  src = pkgs.fetchFromGitHub {
    owner = "luaposix";
    repo = "luaposix";
    rev = "ceb854eab8343ed82e542db20207c2576355d5a0";
    hash = "sha256-F0UfNxHM389GhiPQ6/GFbeKQq5EvpiqQdvyf7ygzkPg=";
  };

  nativeBuildInputs = with pkgs; [
    gcc
    readline
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/lua/${lua.luaversion}
    install -Dm755 ./bin/sketchybar.so $out/lib/lua/${lua.luaversion}/sketchybar.so
    install -Dm755 ./bin/sketchybar.so $out/lib/sketchybar.so
    runHook postInstall
  '';

  meta.platforms = [
    "x86_64-darwin"
    "aarch64-darwin"
  ];
}
