{
  fetchFromGitHub,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "kitty-search";
  version = "0-unstable-2026-05-30";

  src = fetchFromGitHub {
    owner = "Mobinshahidi";
    repo = "kitty-search";
    rev = "bce4fe713b3ba92fcf3b949a71a275d56c19d5f5";
    hash = "sha256-o/IGoxz2cktH6zrP4nXvcKvxWx0PUxMsbSAXgCdIccY=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm444 search.py "$out/share/kitty/kitty-search/search.py"
    runHook postInstall
  '';

  meta = {
    description = "Incremental scrollback search kitten for Kitty";
    homepage = "https://github.com/Mobinshahidi/kitty-search";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
