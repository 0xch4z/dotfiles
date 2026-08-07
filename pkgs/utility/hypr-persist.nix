{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "hypr-persist";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "ngamber";
    repo = "hypr-persist";
    tag = "v${version}";
    hash = "sha256-y1mrwJb4/qEXnlSsc7KGQI++p5fllrHPpoe0tb9Xb+U=";
  };

  # Upstream's development config assumes mold is installed globally.
  postPatch = ''
    rm .cargo/config.toml
  '';

  cargoHash = "sha256-OYJNkWU9Tfx/ZDlO0kfy9sqE0i1YsB9Dy5GR29IAtMI=";

  meta = {
    description = "Session persistence daemon for Hyprland";
    homepage = "https://github.com/ngamber/hypr-persist";
    license = lib.licenses.bsd3;
    mainProgram = "hypr-persist";
    platforms = lib.platforms.linux;
  };
}
