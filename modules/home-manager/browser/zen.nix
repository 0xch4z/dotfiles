{ config, lib, pkgs, self, ... }:
let
  cfg = config.x.home.browser.zen;

  mkZenKeybind = {
    ctrl ? false,
    alt ? false,
    shift ? false,
    meta ? false,
    key
  }: { inherit ctrl alt shift meta key; };
in {
  imports = [ self.inputs.zen-browser.homeModules.beta ];

  options.x.home.browser.zen = {
    enable = lib.mkEnableOption "Enable zen home-manager module.";
  };

  config = lib.mkIf cfg.enable {
      programs.zen-browser = {
        enable = true;

        # Wrap firefox
        # See: https://github.com/0xc000022070/zen-browser-flake/issues/9#issuecomment-2711057434
        #package = self.inputs.zen-browser.packages.${pkgs.system}.default;
        #configPath = ".zen";

        policies = {
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisplayBookmarksToolbar = "never";
          DisplayMenuBar = "default-off";
          DontCheckDefaultBrowser = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          HardwareAcceleration = true;
        };

        profiles.default = {
          extensions = with self.inputs.firefox-addons.packages."${pkgs.system}"; [
            # https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/addons.json?ref_type=head
            bitwarden
            refined-github
            sponsorblock
            ublock-origin
            vimium
            youtube-shorts-block
          ];
          search = {
            default = "DuckDuckGo";
            force = true;

            engines = {
              "Amazon.com".metaData.hidden = true;
              "Bing".metaData.hidden = true;
              "eBay".metaData.hidden = true;

              "Google" = {
                urls = [{
                  template = "https://google.com/search";
                  params = [
                    { name = "q"; value = "{searchTerms}"; }
                  ];
                }];
                definedAliases = [ ",g" ];
              };

              "Github Code Search" = {
                urls = [{
                  template = "https://github.com/search";
                  params = [
                    { name = "type"; value = "code"; }
                    { name = "q"; value = "{searchTerms}"; }
                  ];
                }];
                definedAliases = [ ",gh" ];
              };

              "IETF RFC Search" = {
                urls = [{
                  template = "https://datatracker.ietf.org/doc/search";
                  params = [
                    { name = "rfcs"; value = "on"; }
                    { name = "name"; value = "{searchTerms}"; }
                  ];
                }];
                definedAliases = [ ",rfc" ];
              };

              "MyNix Search" = {
                urls = [{
                  template = "https://mynixos.com/search";
                  params = [
                    { name = "q"; value = "{searchTerms}"; }
                  ];
                }];
                definedAliases = [ ",nix" ];
              };

            };
          };
          bookmarks = [
            {
               name = "Code";
               bookmarks = [
                 {
                   name = "Github";
                   keyword = "gh";
                   url = "https://github.com/";
                 }
                 {
                   name = "Github Notifications";
                   keyword = "gn";
                   url = "https://github.com/notifications";
                 }
                 {
                   name = "Claude";
                   keyword = "c";
                   url = "https://claude.ai";
                 }
              ];
            }
            {
               name = "Research";
               bookmarks = [
                 {
                   name = "RFC Search";
                   keyword = "rfcs";
                   url = "https://datatracker.ietf.org/doc/search?name=%s";
                 }
                 {
                   name = "RFC Doc";
                   keyword = "rfc";
                   url = "https://datatracker.ietf.org/doc/rfc%s/";
                 }
               ];
            }
            {
               name = "Nix";
               bookmarks = [
                 {
                    name = "Nix Options";
                    keyword = "nix";
                    url = "https://search.nixos.org/options?size=200&type=packages&query=%s";
                 }
                 {
                    name = "Nix Packages";
                    keyword = "nixpkgs";
                    url = "https://search.nixos.org/packages?size=200&type=packages&query=%s";
                 }
               ];
            }
          ];
          settings = {
            #https://github.com/zen-browser/desktop/tree/8ef4460f0022a7f4a7211785a0174c50d7fc36a6/src/browser/app/profile
            "zen.theme.accent-color" = "#f6b0ea";
            "zen.urlbar.behavior" = "float";
            "zen.tab-unloader.enable" = true;
            "zen.tab-unloader.timeout-minutes" = 20;
            "zen.view.show-newtab-button-top" = false;
            "zen.keyboard.shortcuts" = builtins.toJSON {
                zenSplitViewHorizontal = mkZenKeybind { meta = true; key = "|"; };
                openNewTab = mkZenKeybind { meta = true; key = "T"; };
                closeTab = mkZenKeybind { meta = true; key = "W"; };
                restoreLastTab = mkZenKeybind { meta = true; shift = true; key = "T"; };
                openNewPrivateWindow = mkZenKeybind { meta = true; shift = true; key = "N"; };
            };

            "gfx.webrender.all" = true;
            "gfx.webrender.force-disabled" = false;
            "layout.css.devPixelsPerPx" = "1.0";

            #"ui.systemUsesDarkTheme" = 1;

            "browser.uidensity" = 1;
            "browser.tabs.drawInTitlebar" = true;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };
        };
      };
  };
}
