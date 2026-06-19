_: {
  den.aspects.chromium.homeManager =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) mkIf;

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

      policies = {
        ExtensionInstallSources = [
          "https://clients2.google.com/service/update2/crx"
          "https://chrome.google.com/webstore/*"
        ];
        BookmarkBarEnabled = false;
        TabGroupsEnabled = false;
        BrowserSigninEnabled = 0;
        SyncDisabled = true;
        PasswordManagerEnabled = false;
        SpellcheckEnabled = true;
        DefaultSearchProviderEnabled = true;
        DefaultSearchProviderName = "Brave";
        DefaultSearchProviderSearchURL = "https://search.brave.com/search?q={searchTerms}";
        DefaultSearchProviderKeyword = "b";
        ManagedBookmarks = shared.toChromiumBookmarks;
        ManagedSearchEngines = [
          {
            name = "Brave";
            keyword = "b";
            search_url = "https://search.brave.com/search?q={searchTerms}";
            is_default = true;
          }
        ]
        ++ shared.toChromiumSearchEngines;
      };
    in
    {
      config = mkIf (!pkgs.stdenv.hostPlatform.isDarwin) {
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "text/html" = "chromium-browser.desktop";
            "x-scheme-handler/http" = "chromium-browser.desktop";
            "x-scheme-handler/https" = "chromium-browser.desktop";
            "x-scheme-handler/about" = "chromium-browser.desktop";
            "x-scheme-handler/unknown" = "chromium-browser.desktop";
          };
        };

        xdg.configFile."mimeapps.list".force = true;

        xdg.configFile."chromium/policies/managed/policies.json".text = builtins.toJSON policies;

        programs.chromium = {
          enable = true;
          package = pkgs.ungoogled-chromium;

          commandLineArgs = [
            "--ozone-platform=x11" # XWayland; native Wayland has WebGL artifacts on Hyprland+NVIDIA
            "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,VaapiOnNvidiaGPUs,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE,WebRTCPipeWireCapturer,WebUIDarkMode,SidePanelPinning"

            "--enable-gpu-rasterization"
            "--ignore-gpu-blocklist"

            # minimal UI
            "--force-dark-mode"
            "--gtk-version=4"
            "--hide-sidepanel-button"
            "--remove-tabsearch-button"
          ];

          dictionaries = [
            pkgs.hunspellDictsChromium.en_US
          ];

          extensions = shared.toChromiumExtensions;
        };
      };
    };
}
