{lib, ...}: {
  options.x.home.theme = {
    font.mono = lib.mkOption {
      type = lib.types.str;
      description = "mono font";
      default = "FiraCode Nerd Font";
    };
  };
}
