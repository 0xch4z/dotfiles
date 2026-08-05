{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.x.home.development.enable {
    home.packages = with pkgs; [
      clang-tools
    ];

    x.home.development.lsp.servers.c = {
      package = pkgs.clang-tools;
      exe = "clangd";
      opencode = "clangd";
      extensionToLanguage = {
        ".c" = "c";
        ".h" = "c";
        ".cpp" = "cpp";
        ".cc" = "cpp";
        ".cxx" = "cpp";
        ".hpp" = "cpp";
        ".hh" = "cpp";
      };
    };
  };
}
