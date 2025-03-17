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
      shell = "${pkgs.fish}/bin/fish";
      terminal = "tmux-256color";
      historyLimit = 100000;

      extraConfig = templateFile {
        file = ./config/tmux.conf;
        data = {
          inherit kubeTmux;

          bash = pkgs.tmux;
        };
      };
    };
}
