# SECRETS
#
# Secrets are stored and encrypted per user (home).
#
# The sops encrypted file is at ${ROOT}/home/${USER}@${HOST}/secrets.enc.yaml.

{ ... }:
{
  den.aspects.home-secrets.homeManager =
    {
      inputs,
      config,
      lib,
      userhost,
      user,
      ...
    }:
    let
      dotfilesDir = "${config.home.homeDirectory}/.dotfiles";

      mkSecret =
        dir: filename:
        let
          sopsFile = "${dir}/${filename}.enc.yaml";
        in
        {
          inherit sopsFile;
          #owner = builtins.trace "owner: ${user}" user;
          format = "yaml";
        };

      # mkGlobalSecret = filename:
      #   (mkSecret "../../secrets" filename);

      # mkUserSecret = filename:
      #   (mkSecret  filename);

      cfg = config.x.home.secrets;
    in
    {
      options.x.home.secrets = {
        keyFile = lib.mkOption {
          type = lib.types.str;
          default = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        };
      };

      imports = [ inputs.sops.homeManagerModules.sops ];

      config = {
        sops = {
          #defaultSopsFile = "../home/chakenne@CHAKENNE-M-2JJJ/secrets/browser.enc.yaml";
          age.keyFile = cfg.keyFile;

          #secrets.userBrowserExtraBookmarks = mkUserSecret "browser";
          #secrets.userBrowserExtraSearchEngines = mkUserSecret "browser";

          secrets."userBrowserExtraBookmarks" = {
            sopsFile = ../home/${userhost}/secrets/browser.enc.yaml;
            key = "userBrowserExtraBookmarks";
          };
        };
      };
    };
}
