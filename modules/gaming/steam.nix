{ ... }:
{
  den.aspects.gaming.nixos =
    { pkgs, ... }:
    let
      bolt-launcher-mangohud = pkgs.symlinkJoin {
        name = "bolt-launcher-mangohud";
        paths = [ pkgs.bolt-launcher ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          rm $out/bin/bolt-launcher
          makeWrapper ${pkgs.mangohud}/bin/mangohud $out/bin/bolt-launcher \
            --add-flags ${pkgs.bolt-launcher}/bin/bolt-launcher
        '';
      };
    in
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };

      programs.gamescope = {
        enable = true;
        capSysNice = true;
      };

      programs.gamemode.enable = true;
      hardware.graphics.enable32Bit = true;

      environment.systemPackages = [
        bolt-launcher-mangohud
      ]
      ++ (with pkgs; [
        mangohud
        protonup-qt
        runelite
        vulkan-tools
      ]);
    };
}
