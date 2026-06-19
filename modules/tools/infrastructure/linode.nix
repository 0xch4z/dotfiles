_: {
  den.aspects.linode.homeManager =
    {
      inputs,
      pkgs,
      ...
    }:
    {
      home = {
        packages = [
          pkgs.linode-cli
          inputs.linodectl.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
    };
}
