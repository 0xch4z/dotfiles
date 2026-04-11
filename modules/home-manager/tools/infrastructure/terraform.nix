{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.tools.infrastructure.terraform.enable {
    home.packages = with pkgs; [
      terraform
      terraform-ls
    ];
  };
}
