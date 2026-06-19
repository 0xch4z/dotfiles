_: {
  den.aspects.terraform.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        terraform
        terraform-ls
      ];
    };
}
