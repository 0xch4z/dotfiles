_: {
  den.aspects.dev-lua.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        luajit
        luajitPackages.lua-lsp
        luajitPackages.luacheck
        luajitPackages.luarocks
        selene
        stylua
        lua-language-server
      ];
      home.sessionPath = [ "$HOME/.luarocks/bin" ];
    };
}
