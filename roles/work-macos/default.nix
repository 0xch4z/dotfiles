{self, pkgs, ...}: {
  imports = [
    ../../pkgs/container/colima
    #../../pkgs/desktop/window-manager/aerospace
    ../common
    ../macos

    self.inputs.gauntlet.homeManagerModules.default
  ];

    programs.gauntlet = {
      enable = true;
      service.enable = true;
      config = {};
    };


  home = {
    packages = with pkgs; [
      _1password
      elixir
      erlang
      # k8s
      kubelogin
      kubelogin-oidc
    ];


    sessionVariables = {
      XDG_RUNTIME_DIR = "$TMPDIR";
    };

    # Needed for nvim-spectre on macOS
    shellAliases = {
      gotask = "/usr/local/bin/task";
      gsed = "sed";
    };
  };
}
