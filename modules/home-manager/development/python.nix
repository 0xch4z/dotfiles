{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.x.home.development.enable {
    x.home.development.lsp.servers.python = {
      package = pkgs.pyright;
      exe = "pyright-langserver";
      args = [ "--stdio" ];
      opencode = "pyright";
      extensionToLanguage = {
        ".py" = "python";
        ".pyi" = "python";
      };
    };

    home = {
      packages = with pkgs; [
        black
        #jupyter
        pyright
        pipenv
        #python3
        ruff
        uv
      ];
    };
  };
}
