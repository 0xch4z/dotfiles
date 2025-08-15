{ pkgs, ... }:

pkgs.tmuxPlugins.mkTmuxPlugin {
  pluginName = "tmux-picker";
  version = "latest";
  src = pkgs.fetchFromGitHub {
    owner = "pawel-wiejacha";
    repo = "tmux-picker";
    rev = "827845f89044fbfb3cd73905f000340bbbda663a";
    sha256 = "sha256-XXB1XmIYhHzDL4JneH1MS3uUolk+QID21IY9xDuwhQI=";
  };
}
