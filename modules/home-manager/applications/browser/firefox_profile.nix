{ self, pkgs, config, ... }:
let
  secrets = config.x.home.secrets;

  extraBookmarks = [];
  # extraBookmarks = if (secrets.enable)
  #   then builtins.fromTOML (builtins.readFile config.sops.secrets.userBrowserExtraBookmarks.path)
  #   else [];

  extraSearchEnginesFile = ./extra_bookmarks.json;
  extraSearchEngines = if builtins.pathExists extraSearchEnginesFile
    then builtins.fromJSON (builtins.readFile extraSearchEnginesFile)
    else [];

  mkZenKeybind = {
    ctrl ? false,
    alt ? false,
    shift ? false,
    meta ? false,
    key
  }: { inherit ctrl alt shift meta key; };
in {
  default = {
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
      default = "ddg";
      force = true;

      engines = {
        "amazon".metaData.hidden = true;
        "bing".metaData.hidden = true;
        "ebay".metaData.hidden = true;

        "google" = {
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
    bookmarks = extraBookmarks ++ [
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
     # zen specific
     #https://github.com/zen-browser/desktop/tree/8ef4460f0022a7f4a7211785a0174c50d7fc36a6/src/browser/app/profile
     "zen.welcome-screen.seen" = true;
     "zen.theme.accent-color" = "#f6b0ea";
     "zen.urlbar.behavior" = "float";
     "zen.tab-unloader.enabled" = true;
     "zen.tab-unloader.timeout-minutes" = 20;
     "zen.view.show-newtab-button-top" = false;
     "zen.workspaces.continue-where-left-off" = true;
     "zen.keyboard.shortcuts" = builtins.toJSON {
         zenSplitViewHorizontal = mkZenKeybind { meta = true; key = "|"; };
         openNewTab = mkZenKeybind { meta = true; key = "T"; };
         closeTab = mkZenKeybind { meta = true; key = "W"; };
         restoreLastTab = mkZenKeybind { meta = true; shift = true; key = "T"; };
         openNewPrivateWindow = mkZenKeybind { meta = true; shift = true; key = "N"; };
     };

     # disable pocket
     "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
     "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
     "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
     "browser.newtabpage.activity-stream.showSponsored" = false;
     "extensions.pocket.enabled" = false;

     # disable page prefetching but keep DNS prefetch for tile loading
     "network.dns.disablePrefetch" = false;
     "network.prefetch-next" = false;
     "network.http.max-persistent-connections-per-server" = 10;
     "network.http.max-connections" = 1800;

     # disable JS in PDFs
     "pdfjs.enableScripting" = false;

     "browser.cache.disk.enable" = true;
     "browser.cache.memory.enable" = true;
     "browser.cache.memory.capacity" = 131072; # 128 MB
     "browser.cache.memory.max_entry_size" = 20480; # 20 MB
     "browser.aboutConfig.showWarning" = false;
     "browser.preferences.defaultPerformanceSettings.enabled" = false;
     "browser.places.speculativeConnect.enabled" = false;
     "middlemouse.paste" = false;

     "gfx.webrender.all" = true;
     "gfx.webrender.force-disabled" = false;
     "media.ffmpeg.vaapi.enabled" = true;
     "media.hardware-video-decoding.force-enabled" = true;
     "widget.dmabuf.force-enabled" = true;
     "layers.acceleration.force-enabled" = true;
     "webgl.force-enabled" = true;
     "webgl.msaa-force" = true;

     # WebGL / Google Maps Street View performance
     # Disable WebGL renderer string sanitization so sites see actual GPU
     "webgl.sanitize-unmasked-renderer" = false;
     "webgl.sanitize-unmasked-vendor" = false;
     "webgl.out-of-process" = true;
     "webgl.out-of-process.force" = true;
     "gfx.canvas.accelerated" = true;
     "gfx.canvas.accelerated.force-enabled" = true;
     "dom.ipc.processCount" = 8;
     "gfx.webrender.precache-shaders" = true;
     "layout.css.devPixelsPerPx" = config.x.home.applications.browser.firefox.devPixelsPerPx;

     "browser.uidensity" = 1;
     "browser.tabs.drawInTitlebar" = true;
     "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    };
  };
}
