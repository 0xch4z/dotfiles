# default.nix for building the is-macbook-display Swift CLI tool

{ pkgs ? import <nixpkgs> { } }:

pkgs.swiftPackages.stdenv.mkDerivation rec {
  pname = "is-macbook-display-only";
  version = "0.1";

  src = ./.;

  nativeBuildInputs = with pkgs; [
    swift
  ];

  buildInputs = with pkgs.darwin.apple_sdk.frameworks; [
    Foundation
    Cocoa
    CoreGraphics
  ];

  buildPhase = ''
    echo "Building ${pname}..."
    export SDKROOT=$(xcrun --show-sdk-path)
    swiftc -framework Foundation -framework Cocoa -framework CoreGraphics main.swift -o ${pname}
  '';

  installPhase = ''
    echo "Installing ${pname} to $out/bin..."
    mkdir -p $out/bin
    cp ${pname} $out/bin/
  '';

  system = pkgs.stdenv.system;

  meta = with pkgs.lib; {
    description = "CLI tool to check MacBook display configuration and notch presence.";
    platforms = platforms.darwin;
  };
}
