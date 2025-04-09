{pkgs, self, ...}:
let
    inherit (self.lib) templateFile;
in {
  programs.tmux =
    let
      kubeTmux = pkgs.fetchFromGitHub {
        owner = "jonmosco";
        repo = "kube-tmux";
        rev = "7f196eeda5f42b6061673825a66e845f78d2449c";
        sha256 = "1dvyb03q2g250m0bc8d2621xfnbl18ifvgmvf95nybbwyj2g09cm";
      };
    in
    {
      enable = true;
      sensibleOnTop = false;
      shell = "${pkgs.fish}/bin/fish";
      terminal = "tmux-256color";
      historyLimit = 100000;

      extraConfig = templateFile {
        file = ./config/tmux.conf;
        data = {
          fish = "${pkgs.fish}";
          kubeTmux = "${kubeTmux}";
          bash = "${pkgs.bash}";
        };
      };

      plugins = with pkgs.tmuxPlugins; [
        pain-control
        tmux-fzf
        tmux-thumbs
      ];
    };
}
