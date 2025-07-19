{ pkgs ? import <nixpkgs> {} }:
let
  version = "1.1.3";
in pkgs.stdenv.mkDerivation rec {
  inherit version;
  pname = "signal";

  buildInputs = [ pkgs.undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p $out/Applications
    cp -r Caffeine.app $out/Applications/Caffeine.app
  '';

  src = pkgs.fetchurl {
    name = "Caffeine.dmg";
    sha256 = "0fx0h5wi1mhlq8cdj995gkmdyqy6dpbd3zxf8fpx0pm26aw5l3i4";
    url = "https://github.com/IntelliScape/caffeine/releases/download/${version}/Caffeine.dmg";
  };

  meta = with pkgs.lib; {
    description = "Caffeine";
    homepage = "https://intelliscapesolutions.com/apps/caffeine";
    platforms = platforms.darwin;
  };
}
