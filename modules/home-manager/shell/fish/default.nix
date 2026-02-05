{self, config, pkgs, ...}:
let
  inherit (self.lib) mkEnabledOption mkIf;
  cfg = config.x.home.shell.fish;
in {
  options.x.home.shell.fish = {
    enable = mkEnabledOption "enable fish shell";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;

      loginShellInit = "fish_add_path --move --prepend --path $HOME/.nix-profile/bin /run/wrappers/bin /etc/profiles/per-user/${config.home.username}/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin";

      interactiveShellInit = ''
        set TERM "xterm-256color"
        set fish_greeting
        set hydro_color_error ff00af
        set hydro_color_git ff00af
        set hydro_color_prompt afff00
        fish_vi_key_bindings

        # hook for local, out-of-band config
        if test -e ~/.fishrc.local
          source ~/.fishrc.local
        end

        # automatic devenv
        # direnv hook fish | source

        # fifc setup
        set -x fifc_editor ${config.home.sessionVariables."EDITOR"}

        # krew setup
        set -q KREW_ROOT; and set -gx PATH $PATH $KREW_ROOT/.krew/bin; or set -gx PATH $PATH $HOME/.krew/bin
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
        # { # clean invalid history search
        #   name = "sponge";
        #   src = sponge.src;
        # }
        { # fzf search mnemonics
          name = "fzf-fish";
          src = fzf-fish.src;
        }
        { # bash "compat"
          name = "bass";
          src = bass.src;
        }
        { # completion
          name = "fifc";
          src = fifc.src;
        }
        { # jump around
          name = "z";
          src = z.src;
        }
      ];

      shellAliases = with pkgs; {
        ls = "${eza}/bin/exa --icons";
        tree = "${eza}/bin/exa --tree";
        cat = "${bat}/bin/bat --theme base16-256";
        kubectl = "${kubecolor}/bin/kubecolor";
      };

      shellAbbrs = {
        # git
        g = "git";
        ga = "git add";
        gc = "git commit";
        gcv = "git commit -v";
        gch = "git checkout";
        gcl = "git clone";
        gb = "git branch";
        gl = "git log --graph --decorate";
        gw = "git worktree";
        gwl = "git worktree list";
        gwm = "git worktree move";
        gp = "git push";
        gpo = "git push origin $(git branch --show-current)";
        gr = "git rebase";
        gri = "git rebase -i";
        gs = "git status";
        gsw = "git switch";
        gst = "git stash";
        gd = "git diff";
        gds = "git diff --staged";
        gdsu = "git diff --staged --unified=0";
        gfo = "git fetch origin";
        gfoa = "git fetch origin --all";

        # (n)vim
        v = "nvim";
        vi = "nvim";
        vim = "nvim";
        n = "nvim";

        l = "ls";
        h = "cd $HOME"; # go $HOME
        w = "cd $HOME/work"; # go to ~/work
        k = "kubectl";
      };
    };
  };
}
