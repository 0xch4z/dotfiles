_: {
  den.aspects.zen.homeManager =
    args@{
      config,
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) mkIf;
      inherit (inputs) zen-browser;

      firefoxPolicies = {
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisplayBookmarksToolbar = "never";
        # DisplayMenuBar = "default-off";
        DontCheckDefaultBrowser = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        HardwareAcceleration = true;
      };

      firefoxProfiles =
        let
          shared =
            let
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

              searchEngines = [
                {
                  id = "google";
                  name = "Google";
                  keyword = "g";
                  searchUrl = "https://google.com/search?q={searchTerms}";
                }
                {
                  id = "github-code-search";
                  name = "Github Code Search";
                  keyword = "gh";
                  searchUrl = "https://github.com/search?type=code&q={searchTerms}";
                }
                {
                  id = "nix-packages";
                  name = "Nix Packages";
                  keyword = "nix";
                  searchUrl = "https://search.nixos.org/packages?query={searchTerms}";
                }
              ];

              sharedExtensions = [
                {
                  name = "bitwarden";
                  firefox = "bitwarden";
                  chromiumId = "nngceckbapebfimnlniiiahkandclblb";
                }
                {
                  name = "ublock-origin";
                  firefox = "ublock-origin";
                  chromiumId = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
                }
                {
                  name = "vimium";
                  firefox = "vimium";
                  chromiumId = "dbepggeogbaibhgnhhndojpepiihcmeb";
                }
              ];

              firefoxOnlyExtensions = [
                "refined-github"
                "sponsorblock"
                "youtube-shorts-block"
              ];

              chromiumOnlyExtensions = [
                { id = "ocaahdebbfolfmndjeplogmgcagdmblk"; } # chromium web store
              ];

              bookmarkToChromium =
                bm:
                if bm ? bookmarks then
                  {
                    name = bm.name;
                    children = map bookmarkToChromium bm.bookmarks;
                  }
                else
                  {
                    name = bm.name;
                    url = bm.url;
                  };

              toChromiumBookmarks = map bookmarkToChromium bookmarks;

              toChromiumSearchEngines = map (
                e:
                {
                  name = e.name;
                  keyword = e.keyword;
                  search_url = e.searchUrl;
                }
                // lib.optionalAttrs (e ? isDefault && e.isDefault) {
                  is_default = true;
                }
              ) searchEngines;

              toChromiumExtensions =
                (map (e: { id = e.chromiumId; }) sharedExtensions) ++ chromiumOnlyExtensions;

              toFirefoxSearchEngines = builtins.listToAttrs (
                map (
                  e:
                  let
                    parts = lib.splitString "?" e.searchUrl;
                    template = builtins.head parts;
                    paramStr = if builtins.length parts > 1 then builtins.elemAt parts 1 else "";
                    paramPairs = if paramStr == "" then [ ] else lib.splitString "&" paramStr;
                    params = map (
                      p:
                      let
                        kv = lib.splitString "=" p;
                      in
                      {
                        name = builtins.head kv;
                        value = builtins.elemAt kv 1;
                      }
                    ) paramPairs;
                  in
                  {
                    name = e.id;
                    value = {
                      urls = [ { inherit template params; } ];
                      definedAliases = [ ",${e.keyword}" ];
                    };
                  }
                ) searchEngines
              );

              toFirefoxExtensions =
                firefoxAddons:
                let
                  shared = map (e: firefoxAddons.${e.firefox}) sharedExtensions;
                  extras = map (name: firefoxAddons.${name}) firefoxOnlyExtensions;
                in
                shared ++ extras;
            in
            {
              inherit
                bookmarks
                searchEngines
                sharedExtensions
                toChromiumBookmarks
                toChromiumSearchEngines
                toChromiumExtensions
                toFirefoxSearchEngines
                toFirefoxExtensions
                ;
            };

          firefoxAddons = inputs.firefox-addons.packages."${pkgs.stdenv.hostPlatform.system}";

          secrets = config.x.home.secrets;

          extraBookmarks = [ ];
          # extraBookmarks = if (secrets.enable)
          #   then builtins.fromTOML (builtins.readFile config.sops.secrets.userBrowserExtraBookmarks.path)
          #   else [];

          mkZenKeybind =
            {
              ctrl ? false,
              alt ? false,
              shift ? false,
              meta ? false,
              key,
            }:
            {
              inherit
                ctrl
                alt
                shift
                meta
                key
                ;
            };
        in
        {
          default = {
            extensions.packages = shared.toFirefoxExtensions firefoxAddons;
            search = {
              default = "ddg";
              force = true;

              engines = shared.toFirefoxSearchEngines // {
                "amazon".metaData.hidden = true;
                "bing".metaData.hidden = true;
                "ebay".metaData.hidden = true;

                # Firefox-only search engines
                "ietf-rfc-search" = {
                  urls = [
                    {
                      template = "https://datatracker.ietf.org/doc/search";
                      params = [
                        {
                          name = "rfcs";
                          value = "on";
                        }
                        {
                          name = "name";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  definedAliases = [ ",rfc" ];
                };

                "mynix-search" = {
                  urls = [
                    {
                      template = "https://mynixos.com/search";
                      params = [
                        {
                          name = "q";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  definedAliases = [ ",mnix" ];
                };
              };
            };
            bookmarks = {
              force = true;
              settings = extraBookmarks ++ shared.bookmarks;
            };
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
                zenSplitViewHorizontal = mkZenKeybind {
                  meta = true;
                  key = "|";
                };
                openNewTab = mkZenKeybind {
                  meta = true;
                  key = "T";
                };
                closeTab = mkZenKeybind {
                  meta = true;
                  key = "W";
                };
                restoreLastTab = mkZenKeybind {
                  meta = true;
                  shift = true;
                  key = "T";
                };
                openNewPrivateWindow = mkZenKeybind {
                  meta = true;
                  shift = true;
                  key = "N";
                };
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
        };
    in
    {
      imports = [ zen-browser.homeModules.beta ];

      config = mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
        programs.zen-browser = {
          enable = true;

          # can't install via home-manager on darwin yet :(
          # finalPackage =
          #   mkForce (mkIf pkgs.stdenv.hostPlatform.isDarwin (mkForce null));

          policies = firefoxPolicies;
          profiles = firefoxProfiles;
        };
      };
    };
}
