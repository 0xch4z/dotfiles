{
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      black
      jupyter
      #pyright
      #python3
    ];
  };
}
