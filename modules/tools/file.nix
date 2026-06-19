_: {
  den.aspects.file.homeManager =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          file
          fzf
          glow
          xz
          zoekt
        ];
      };

      programs.yazi = {
        enable = true;
        package = pkgs.unstable.yazi;
        shellWrapperName = "y";

        enableFishIntegration = true;

        settings = {
          mgr.show_hidden = true;
        };
        plugins = {
          smart-enter = pkgs.unstable.yaziPlugins.smart-enter;
        };
        keymap = {
          mgr.prepend_keymap = [
            {
              on = "<Enter>";
              run = "plugin --sync smart-enter";
              desc = "enter child directory or open file";
            }
            {
              on = "n";
              run = "create";
              desc = "create file or directory";
            }
            {
              on = ".";
              run = "hidden toggle";
              desc = "toggle hidden files";
            }
            {
              on = [
                "c"
                "c"
              ];
              run = "copy path";
              desc = "copy absolute path";
            }
          ];
        };
      };
    };
}
