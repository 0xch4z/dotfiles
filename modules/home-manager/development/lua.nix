{pkgs, config, lib, ...}: {
  config = lib.mkIf config.x.home.development.enable {
    home.packages = with pkgs; [
      luajit
      luajitPackages.lua-lsp
      luajitPackages.luacheck
      luajitPackages.luarocks
      selene
      stylua
      sumneko-lua-language-server
    ];
    home.sessionPath = [
      "$HOME/.luarocks/bin"
    ];
  };
}
