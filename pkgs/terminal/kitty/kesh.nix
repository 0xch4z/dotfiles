{
  fetchurl,
  gnutar,
  gzip,
  lib,
  stdenvNoCC,
}:
let
  version = "0.1.1";
  assets = {
    aarch64-darwin = {
      name = "darwin_arm64";
      hash = "sha256-teN0YK1uhu/YS3MS69dyMwQtL1gxyg7rtlCKuRYvX+E=";
    };
    x86_64-darwin = {
      name = "darwin_amd64";
      hash = "sha256-wJqaozphRsiqnbLyFOLjQxNLME2GZ/+sA8vH3borNS0=";
    };
    x86_64-linux = {
      name = "linux_amd64";
      hash = "sha256-CYsNAIX37T7XjvdEbd2jG1UrzUra06++DB1oGN8LqYg=";
    };
  };
  asset =
    assets.${stdenvNoCC.hostPlatform.system}
      or (throw "kesh is unsupported on ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "kesh";
  inherit version;

  src = fetchurl {
    url = "https://github.com/alienxp03/kesh/releases/download/v${version}/kesh_${version}_${asset.name}.tar.gz";
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
    install -Dm755 kesh "$out/bin/kesh"
    runHook postInstall
  '';

  meta = {
    description = "Keyboard-driven Kitty session manager";
    homepage = "https://github.com/alienxp03/kesh";
    license = lib.licenses.unfree;
    mainProgram = "kesh";
    platforms = builtins.attrNames assets;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
