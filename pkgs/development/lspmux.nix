{
  fetchFromCodeberg,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "lspmux";
  version = "0.3.0-unstable-2026-03-11";

  src = fetchFromCodeberg {
    owner = "p2502";
    repo = "lspmux";
    rev = "18861f9d59e74ece8d867772cf07fa302c2dae98";
    hash = "sha256-OchqUe8GdBPL6tE3zpdaThfhzYZhYluagz1yXiexFT0=";
  };

  cargoHash = "sha256-Xm+tFRZux0UdolZMS9UI17OIcVH+/56vSu/nF11GVWE=";

  meta = {
    description = "Share one language server instance between multiple LSP clients";
    homepage = "https://codeberg.org/p2502/lspmux";
    license = lib.licenses.eupl12;
    mainProgram = "lspmux";
  };
}
