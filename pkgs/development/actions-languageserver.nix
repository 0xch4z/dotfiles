{
  lib,
  buildNpmPackage,
  fetchurl,
}:
buildNpmPackage rec {
  pname = "actions-languageserver";
  version = "0.3.46";

  src = fetchurl {
    url = "https://registry.npmjs.org/@actions/languageserver/-/languageserver-${version}.tgz";
    hash = "sha256-dmHxpcldOSmUYi3n3WsVKIGjuXw6oqfevYOMxjAvcVA=";
  };
  sourceRoot = "package";

  npmDepsHash = "sha256-/oo/4abOilHnSBVYmTn9BPRdpKp0n1fD5IQq81ypCss=";
  npmBuildScript = "build";
  dontNpmBuild = true;

  postPatch = ''
    cp ${./actions-languageserver-package-lock.json} package-lock.json
  '';

  meta = {
    description = "Language server for GitHub Actions";
    homepage = "https://github.com/actions/languageservices";
    license = lib.licenses.mit;
    mainProgram = "actions-languageserver";
    platforms = lib.platforms.unix;
  };
}
