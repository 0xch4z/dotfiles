{
  pkgs,
  lib,
  stdenv,
}:
let
  version = "1.0.0-alpha.4";

  srcs = {
    aarch64-darwin = {
      url = "https://github.com/agentgateway/agentgateway/releases/download/v${version}/agentgateway-darwin-arm64";
      sha256 = "5e9450f6acf885a9a8c509400b4989d201ebb85c9151c471865c3df5e26af2b1";
    };
    x86_64-linux = {
      url = "https://github.com/agentgateway/agentgateway/releases/download/v${version}/agentgateway-linux-amd64";
      sha256 = "ed08f4c0f2d62b8fb7424569565e3c80be93080f22caced5775f92aac921aff9";
    };
    aarch64-linux = {
      url = "https://github.com/agentgateway/agentgateway/releases/download/v${version}/agentgateway-linux-arm64";
      sha256 = "e2a8caecade160f3431bd66b80a466033efebb9e8be1ddc977ac979682901668";
    };
  };

  src = srcs.${stdenv.hostPlatform.system} or (throw "unsupported platform: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "agentgateway";
  inherit version;

  src = pkgs.fetchurl {
    inherit (src) url sha256;
    name = "agentgateway";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/agentgateway
    chmod +x $out/bin/agentgateway
  '';

  meta = with lib; {
    description = "Next generation agentic proxy for AI agents and MCP servers";
    homepage = "https://github.com/agentgateway/agentgateway";
    platforms = builtins.attrNames srcs;
    mainProgram = "agentgateway";
  };
}
