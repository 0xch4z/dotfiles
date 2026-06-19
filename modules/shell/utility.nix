{ ... }:
{
  den.aspects.shell-utility.homeManager =
    { pkgs, ... }:
    let
      shelp = pkgs.writeShellApplication {
        name = "shelp";
        text = builtins.readFile ./scripts/shelp.sh;
      };
    in
    {
      programs.zoxide = {
        enable = true;
      };

      programs.bash = {
        enable = true;
      };

      home.packages = with pkgs; [
        shelp
        bash-language-server
      ];
    };
}
