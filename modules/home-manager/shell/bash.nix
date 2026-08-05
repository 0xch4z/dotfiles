{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (self.lib) mkEnabledOption;
  cfg = config.x.home.shell.bash;
  user = config.home.username;
in
{
  options.x.home.shell.bash = {
    enable = mkEnabledOption "enable Bash shell";
  };

  config = lib.mkIf cfg.enable {
    x.home.development.lsp.servers.bash = {
      package = pkgs.bash-language-server;
      args = [ "start" ];
      opencode = "bash";
      extensionToLanguage = {
        ".sh" = "shellscript";
        ".bash" = "shellscript";
      };
    };

    home.packages = with pkgs; [
      bash-language-server
      bat
      eza
      grc
    ];

    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyFileSize = 100000;
      historySize = 10000;

      profileExtra = ''
        __x_path_remove() {
          local target=$1
          local old_path=$PATH
          local part
          local old_ifs=$IFS

          PATH=
          IFS=:
          for part in $old_path; do
            [ "$part" = "$target" ] && continue
            [ -n "$part" ] || continue
            PATH="''${PATH:+$PATH:}$part"
          done
          IFS=$old_ifs
        }

        __x_path_prepend() {
          [ -d "$1" ] || return
          __x_path_remove "$1"
          PATH="$1''${PATH:+:$PATH}"
        }

        __x_path_append() {
          [ -d "$1" ] || return
          case ":$PATH:" in
            *":$1:"*) ;;
            *) PATH="''${PATH:+$PATH:}$1" ;;
          esac
        }

        __x_path_prepend "/nix/var/nix/profiles/default/bin"
        __x_path_prepend "/run/current-system/sw/bin"
        __x_path_prepend "/run/system-manager/sw/bin"
        __x_path_prepend "/etc/profiles/per-user/${user}/bin"
        __x_path_prepend "/run/wrappers/bin"
        __x_path_prepend "$HOME/.nix-profile/bin"

        if [ -n "''${KREW_ROOT:-}" ]; then
          __x_path_append "$KREW_ROOT/.krew/bin"
        else
          __x_path_append "$HOME/.krew/bin"
        fi

        export PATH
        unset -f __x_path_remove __x_path_prepend __x_path_append
      '';

      initExtra = ''
        export TERM="''${TERM:-xterm-256color}"
        export fifc_editor="''${EDITOR:-nvim}"

        if [ -e "$HOME/.bashrc.local" ]; then
          . "$HOME/.bashrc.local"
        fi

        if command -v direnv >/dev/null 2>&1; then
          eval "$(direnv hook bash)"
        fi
      '';

      shellAliases = {
        ls = "${pkgs.eza}/bin/eza --icons";
        tree = "${pkgs.eza}/bin/eza --tree";
        cat = "${pkgs.bat}/bin/bat --theme base16-256";
        kubectl = "${pkgs.kubecolor}/bin/kubecolor";
        k = "kubectl";
      };
    };
  };
}
