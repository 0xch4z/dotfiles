{ pkgs, ... }:
{
  imports = [
   ../common.nix
   ../../home/programs/neovim
 ];
 home.packages = with pkgs; [
   zlib
 ];
}
