{ config, ... }: {
  programs.git = {
    settings.user.email = "me@ch4z.io";
    settings.user.name = "Charlie Kenney";
  };
  home.sessionPath = [ "$HOME/.local/bin" ];
}
