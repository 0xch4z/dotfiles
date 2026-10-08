{
  fetchFromGitHub,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "kitty-action-menu";
  version = "0-unstable-2026-07-27";

  src = fetchFromGitHub {
    owner = "olispeedy";
    repo = "kitty-action-menu";
    rev = "9cbda49c85af91bc2c651e74b68b75b4ad81c158";
    hash = "sha256-3/+uuDAR3EluTcfxB4t1i6CWN639dznQpp/Ashi9sD8=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm444 config/user/action_menu.py "$out/share/kitty/kitty-action-menu/action_menu.py"
    runHook postInstall
  '';

  meta = {
    description = "Pop-up action menu for Kitty";
    homepage = "https://github.com/olispeedy/kitty-action-menu";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
}
