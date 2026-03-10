# Shared browser configuration across Firefox, Zen, and Chromium.
# Defines bookmarks, search engines, and extensions in a canonical format
# with mapping functions to each browser's native format.
{ lib }:
let
  # ── Bookmarks ──────────────────────────────────────────────────────
  # Firefox/Zen native format: { name, keyword?, url?, bookmarks? }
  bookmarks = [
    {
      name = "Code";
      bookmarks = [
        { name = "Github";              keyword = "gh"; url = "https://github.com/"; }
        { name = "Github Notifications"; keyword = "gn"; url = "https://github.com/notifications"; }
        { name = "Claude";              keyword = "c";  url = "https://claude.ai"; }
      ];
    }
    {
      name = "Research";
      bookmarks = [
        { name = "RFC Search"; keyword = "rfcs"; url = "https://datatracker.ietf.org/doc/search?name=%s"; }
        { name = "RFC Doc";    keyword = "rfc";  url = "https://datatracker.ietf.org/doc/rfc%s/"; }
      ];
    }
    {
      name = "Nix";
      bookmarks = [
        { name = "Nix Options";  keyword = "nix";    url = "https://search.nixos.org/options?size=200&type=packages&query=%s"; }
        { name = "Nix Packages"; keyword = "nixpkgs"; url = "https://search.nixos.org/packages?size=200&type=packages&query=%s"; }
      ];
    }
  ];

  # ── Search engines ─────────────────────────────────────────────────
  # Canonical format shared across browsers.
  searchEngines = [
    { id = "google";             name = "Google";             keyword = "g";  searchUrl = "https://google.com/search?q={searchTerms}"; }
    { id = "github-code-search"; name = "Github Code Search"; keyword = "gh"; searchUrl = "https://github.com/search?type=code&q={searchTerms}"; }
    { id = "nix-packages";       name = "Nix Packages";       keyword = "nix"; searchUrl = "https://search.nixos.org/packages?query={searchTerms}"; }
  ];

  # ── Extensions ─────────────────────────────────────────────────────
  # Extensions present in both Firefox/Zen and Chromium.
  sharedExtensions = [
    { name = "bitwarden";    firefox = "bitwarden";    chromiumId = "nngceckbapebfimnlniiiahkandclblb"; }
    { name = "ublock-origin"; firefox = "ublock-origin"; chromiumId = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
    { name = "vimium";       firefox = "vimium";       chromiumId = "dbepggeogbaibhgnhhndojpepiihcmeb"; }
  ];

  # Firefox/Zen-only extensions (package names from firefox-addons)
  firefoxOnlyExtensions = [
    "refined-github"
    "sponsorblock"
    "youtube-shorts-block"
  ];

  # Chromium-only extensions (by ID)
  chromiumOnlyExtensions = [
    { id = "ocaahdebbfolfmndjeplogmgcagdmblk"; } # chromium web store
  ];

  # ── Mapping functions ─────────────────────────────────────────────

  # Convert a single bookmark entry to Chromium ManagedBookmarks format.
  # Chromium uses { name, url } for items and { name, children } for folders.
  bookmarkToChromium = bm:
    if bm ? bookmarks then {
      name = bm.name;
      children = map bookmarkToChromium bm.bookmarks;
    } else {
      name = bm.name;
      url = bm.url;
    };

  toChromiumBookmarks = map bookmarkToChromium bookmarks;

  toChromiumSearchEngines = map (e: {
    name = e.name;
    keyword = e.keyword;
    search_url = e.searchUrl;
  } // lib.optionalAttrs (e ? isDefault && e.isDefault) {
    is_default = true;
  }) searchEngines;

  toChromiumExtensions =
    (map (e: { id = e.chromiumId; }) sharedExtensions)
    ++ chromiumOnlyExtensions;

  # Firefox search engines — convert to the engines attrset format.
  # Each engine: { urls = [{ template; params }]; definedAliases = [ ",keyword" ]; }
  toFirefoxSearchEngines = builtins.listToAttrs (map (e:
    let
      # Split searchUrl at "?" to extract template and params
      parts = lib.splitString "?" e.searchUrl;
      template = builtins.head parts;
      paramStr = if builtins.length parts > 1 then builtins.elemAt parts 1 else "";
      paramPairs = if paramStr == "" then [] else lib.splitString "&" paramStr;
      params = map (p:
        let kv = lib.splitString "=" p;
        in { name = builtins.head kv; value = builtins.elemAt kv 1; }
      ) paramPairs;
    in {
      name = e.id;
      value = {
        urls = [{ inherit template params; }];
        definedAliases = [ ",${e.keyword}" ];
      };
    }
  ) searchEngines);

  # Get Firefox extension packages from the addons flake.
  toFirefoxExtensions = firefoxAddons:
    let
      shared = map (e: firefoxAddons.${e.firefox}) sharedExtensions;
      extras = map (name: firefoxAddons.${name}) firefoxOnlyExtensions;
    in shared ++ extras;

in {
  inherit
    bookmarks
    searchEngines
    sharedExtensions
    toChromiumBookmarks
    toChromiumSearchEngines
    toChromiumExtensions
    toFirefoxSearchEngines
    toFirefoxExtensions;
}
