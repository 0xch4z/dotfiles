{ lib, fetchFromGitHub, buildGoModule }:

with lib;

buildGoModule rec {
  pname = "ct";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "coreos";
    repo = "container-linux-config-transpiler";
    rev = "v${version}";
    sha256 = "058zjk9yqgdli55gc6y48455il6wjpslyz2r2ckk2ki9c5qc8b7c";
  };

   subPackages = [ "./internal" ];

   vendorHash = "sha256-WkRcOp8pywP/XOgD9iK3RwI7KCQcXdjx4QnjShE/d2w=";

   preBuild = ''
     GOPROXY="https://proxy.golang.org,direct"
     export buildFlagsArray=(
       -mod="readonly"
     )
   '';

   # vendor inconsistencies
   deleteVendor = true;

   # don't run tests
   doCheck = false;

   patches = [
     ./container-linux-config-transpiler.0001-convert-to-gomod.patch
   ];

   meta = {
     description = "Convert a Container Linux Config into Ignition";
     license = licenses.asl20;
     homepage = "https://github.com/coreos/container-linux-config-transpiler";
   };
}
