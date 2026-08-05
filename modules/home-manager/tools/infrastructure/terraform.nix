{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.x.home.tools.infrastructure.terraform.enable {
    home.packages = with pkgs; [
      terraform
      terraform-ls
    ];

    x.home.development.lsp.servers.terraform = {
      package = pkgs.terraform-ls;
      args = [ "serve" ];
      opencode = "terraform";
      extensionToLanguage = {
        ".tf" = "terraform";
        ".tfvars" = "terraform";
      };
    };
  };
}
