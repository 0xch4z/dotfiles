{ pkgs, config, lib, ... }:
let
  # TODO: actually implement
  # inherit (config.x.home) secrets;
  inherit (config.sops.secrets) userBrowserExtraBookmarks;

  prepareBookmarksScript = pkgs.writeShellScript "prepare-bookmarks.sh" ''
    #!/usr/bin/env bash

    INPUT_YAML=$1
    OUTPUT_HTML=$2

    echo TODO

    echo "TODO" > "$OUTPUT_HTML"
  '';

  serviceName = "home-manager-bookmarks";
  bookmarksPath = "$HOME/.local/state/io.0xch4z.${serviceName}/bookmarks.html";
  serviceCommand = "${prepareBookmarksScript} #{userBrowserExtraBookmarks.path} ${bookmarksPath}";
in {
    # launchd.user.agents.${serviceName} = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    #   inherit description serviceConfig;

    #   wantedBy = [ "multi-user.target" ];
    # };

    # systemd.user.services.${serviceName} = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    #   Unit = {
    #     Description = "sops-nix activation";
    #   };
    #   Service = serviceConfig;
    # };

    launchd.agents.${serviceName} = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      enable = true;
      config = {
        Program = serviceCommand;
        KeepAlive = false;
        RunAtLoad = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/${serviceName}/stdout";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/${serviceName}/stderr";
      };
    };
}
