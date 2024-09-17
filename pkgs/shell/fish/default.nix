{pkgs, ...}: {
  programs.fish = {
    enable = true;

    loginShellInit = "fish_add_path --move --prepend --path $HOME/.nix-profile/bin /run/wrappers/bin /etc/profiles/per-user/$USER/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin";

    interactiveShellInit = ''
      set TERM "xterm-256color"
      set fish_greeting
      set hydro_color_error ff00af
      set hydro_color_git ff00af
      set hydro_color_prompt afff00
      fish_vi_key_bindings

      # automatic devenv
      direnv hook fish | source
    '';

    plugins = with pkgs.fishPlugins; [
      { # prompt
        name = "hydro";
        src = hydro.src;
      }
      {
        name = "grc";
        src = grc.src;
      }
      { # auto-match symbols
        name = "pisces";
        src = pisces.src;
      }
      { # clean invalid history search
        name = "sponge";
        src = sponge.src;
      }
      { # fzf search mnemonics
        name = "fzf-fish";
        src = fzf-fish.src;
      }
    ];

    shellAbbrs = with pkgs; {
      gh = "cd $HOME";
      n = "nvim";
      k = "kubectl";
      l = "${eza}/bin/exa --icons";
      tree = "${eza}/bin/exa --tree";
    };
  };
}
