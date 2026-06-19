_: {
  den.aspects.dev-git.homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    let
      git-alias-wpr = pkgs.writeShellApplication {
        name = "git-alias-wpr";
        runtimeInputs = [
          pkgs.git
        ];
        text = ''
          shelp --name "git wpr" "name|dir" "ref?|base" -- "$@" || exit 1
          git worktree add "$1" -b "pr/ck/$1" "''${2:-HEAD}"
        '';
      };
      git-alias-wb = pkgs.writeShellApplication {
        name = "git-alias-wb";
        runtimeInputs = with pkgs; [
          git
          gum
          fzf
          gnugrep
        ];
        text = ''
          shelp --name "git wb" "query?|" -- "$@" || exit 1
          declare -A branch_path
          while IFS= read -r line; do
            path=$(awk '{print $1}' <<< "$line")
            branch=$(grep -oP '(?<=\[).+(?=\])' <<< "$line" || true)
            [[ -n "$branch" ]] && branch_path["$branch"]="$path"
          done < <(git worktree list | tail -n +2)

          branch="$(printf '%s\n' "''${!branch_path[@]}" \
            | fzf --height=~20% --layout reverse --style minimal -i -q "''${1:-}")"
          [[ -n "$branch" ]] || exit 1
          path="''${branch_path[$branch]}"
          echo "Found directory $(gum style --foreground 12 "$path") $(gum style --foreground 11 "(branch $branch)")" >&2
          printf '%s' "$path"
          echo "" >&2
        '';
      };
    in
    {
      home.packages = with pkgs; [
        git-absorb
        delta
        diffnav
      ];

      programs.git = {
        enable = true;
        ignores = [
          ".actrc"
          ".bazelrc.local"
          ".direnv"
          ".envrc"
          ".nvim.lua"
          ".zoekt"
          ".agent*.md"
        ];

        settings = {
          alias = {
            fuck = "reset HEAD --hard";
            a = "commit --amend";
            amend = "commit --amend --no-edit";
            s = "commit --amend -s";
            c = "commit -v";
            l = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
            la = "l --all";
            last = "log -1 HEAD --stat";
            undo = "reset --soft HEAD~1";
            unstage = "restore --staged";
            please = "push --force-with-lease";
            fixup = "!git absorb --and-rebase";
            wt = "worktree";
            wb = "!${git-alias-wb}/bin/git-alias-wb";
            wpr = "!${git-alias-wpr}/bin/git-alias-wpr";
            redo = "rebase -i HEAD~1";
          };

          color = {
            ui = true;
            diff = {
              meta = "yellow";
              frag = "magenta bold";
              old = "red bold";
              new = "green bold";
            };
            branch = {
              current = "yellow reverse";
              local = "yellow";
              remote = "green";
            };
            status = {
              added = "green";
              changed = "yellow";
              untracked = "cyan";
            };
          };
          commit.verbose = true;

          diff = {
            algorithm = "histogram";
            colorMoved = "zebra";
            colorMovedWS = "allow-indentation-change";
            mnemonicPrefix = true;
            renames = "copies";
          };

          rerere = {
            enabled = true;
            autoUpdate = true;
          };

          merge = {
            conflictStyle = "zdiff3";
          };

          fetch = {
            prune = true;
            pruneTags = true;
            all = true;
          };

          push = {
            autoSetupRemote = true;
            followTags = true;
          };

          pull.rebase = true;

          rebase = {
            autoStash = true;
            autoSquash = true;
            updateRefs = true;
            missingCommitsCheck = "error";
          };

          branch.sort = "-committerdate";
          tag.sort = "version:refname";

          grep = {
            lineNumber = true;
            patternType = "perl";
          };

          status = {
            showStash = true;
            submoduleSummary = true;
          };

          log.date = "iso";
          blame.markUnblamableLines = true;

          pager = {
            diff = "diffnav";
            show = "diffnav";
            log = "delta";
            blame = "delta";
          };
          interactive.diffFilter = "delta --color-only";

          delta = {
            navigate = true;
            line-numbers = true;
            side-by-side = true;
            hyperlinks = true;
            true-color = "always";
          };

          url."git@github.com:".insteadOf = "https://github.com/";

          help.autocorrect = "prompt";
          init.defaultBranch = "main";
          transfer.fsckObjects = true;
          worktree.guessRemote = true;
          extensions.worktreeConfig = true;
          column.ui = "auto";
          core.untrackedCache = true;
          core.fsmonitor = true;
          branch.autoSetupRebase = "always";

          # per-directory identity
          # includeIf."gitdir:~/work/".path = "~/.config/git/work";
        };

        maintenance.enable = true;

        signing = {
          signByDefault = true;
          format = "ssh";
          key = "~/.ssh/id_ed25519.pub";
        };
      };

      programs.gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
          prompt = "enabled";
          editor = "nvim";
          pager = "delta";

          aliases = {
            co = "pr checkout";
            pv = "pr view --web";
            rv = "pr review";
            prc = "pr create --fill";
            prs = "pr status";
            iss = "issue list --web";
            sync = "repo sync";
          };
        };

        extensions = with pkgs; [
          gh-dash
          gh-eco
          gh-poi
          gh-markdown-preview
        ];
      };

      xdg.configFile."gh-dash/config.yml".text = ''
        prSections:
          - title: My Pull Requests
            filters: is:open author:@me
          - title: Needs My Review
            filters: is:open review-requested:@me
          - title: Involved
            filters: is:open involves:@me -author:@me
        defaults:
          preview:
            open: true
      '';
    };
}
