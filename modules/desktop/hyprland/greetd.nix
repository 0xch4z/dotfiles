{ ... }:
{
  den.aspects.hypr-greetd.homeManager =
    {
      ...
    }:
    {
      config = {
        # TODO: figure out how to do this with hm
        # services.greetd = {
        #   enable = true;

        #   vt = 2;
        #   settings = {
        #     default_session = {
        #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        #       user = "greeter";
        #     };
        #   };
        # };
      };
    };
}
