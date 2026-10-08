{
  fetchurl,
  gnutar,
  gzip,
  lib,
  stdenvNoCC,
}:
let
  version = "0.9.1";
  assets = {
    aarch64-darwin = {
      name = "Darwin_arm64";
      hash = "sha256-kNApWCqWwoPJAYkO2bBwnqQKuBFU371hZxYd+SaGreE=";
    };
    x86_64-darwin = {
      name = "Darwin_x86_64";
      hash = "sha256-OVdT5LDQcVORgauQcvvZ3R5af/f+RFiCZlnH2JQ1pcM=";
    };
    aarch64-linux = {
      name = "Linux_arm64";
      hash = "sha256-DIh9usF2ej4xg1O2x5Q+hWtwoazVz0aCEauv9V6PJaA=";
    };
    x86_64-linux = {
      name = "Linux_x86_64";
      hash = "sha256-MZ12eVZ1v1BACIdddZN/lwN6pyy0/lZQNRHyJrK89Vw=";
    };
  };
  asset =
    assets.${stdenvNoCC.hostPlatform.system}
      or (throw "tuios is unsupported on ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "tuios";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Gaurav-Gosain/tuios/releases/download/v${version}/tuios_${version}_${asset.name}.tar.gz";
    inherit (asset) hash;
  };

  dontUnpack = true;
  nativeBuildInputs = [
    gnutar
    gzip
  ];

  installPhase = ''
    runHook preInstall
    tar -xzf "$src"
    install -Dm755 tuios "$out/bin/tuios"
    runHook postInstall
  '';

  meta = {
    description = "Persistent terminal multiplexer and window manager";
    homepage = "https://tuios.dev";
    license = lib.licenses.mit;
    mainProgram = "tuios";
    platforms = builtins.attrNames assets;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
