{ ... }:
{
  den.aspects.hypr-paper.homeManager =
    {
      config,
      ...
    }:
    let
      wallpaper = "${config.home.homeDirectory}/.dotfiles/assets/philly-dark.jpg";

      g8 = "desc:Samsung Electric Company Odyssey G80SD H1AK500000";
    in
    {
      config = {
        services.hyprpaper = {
          enable = true;
          settings = {
            ipc = "on";
            splash = false;

            preload = [ wallpaper ];
            wallpaper = [ "${g8},${wallpaper}" ];
          };
        };
      };
    };
}
