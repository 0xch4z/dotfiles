{ ... }:
{
  den.aspects.hypr-cursor.homeManager =
    {
      pkgs,
      ...
    }:
    {
      config = {
        home.packages = with pkgs; [
          capitaine-cursors
        ];

        home.pointerCursor = {
          name = "capitaine-cursors";
          package = pkgs.capitaine-cursors;
          size = 24;
          gtk.enable = true;
          x11.enable = true;
        };
      };
    };
}
