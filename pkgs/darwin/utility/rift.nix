{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rift";
  version = "0.6.9";

  src = fetchFromGitHub {
    owner = "acsandmann";
    repo = "rift";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MuXUyQ0b4v66yPwrfefCHaYGL7zo9hg1QJq4ve0kFCQ=";
  };

  cargoHash = "sha256-JHB6yqrOuwZ+UwxSKBp9eh0bX4mkZndxQvHEtCclxPk=";

  # the native suite drives a live window server
  doCheck = false;

  meta = {
    description = "Tiling window manager for macOS";
    homepage = "https://github.com/acsandmann/rift";
    license = lib.licenses.asl20;
    mainProgram = "rift";
    platforms = lib.platforms.darwin;
  };
})
