{ pkgs, ... }:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
  policies = {
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    EnableTrackingProtection = {
      Value = true;
      Locked = true;
      Cryptomining = true;
      Fingerprinting = true;
    };
    DisablePocket = true;
    DisableFirefoxAccounts = true;
    DisableAccounts = true;
    DisplayBookmarksToolbar = "never";
    SearchBar = "unified";

    Preferences = {
      # Disable pocket
      "extensions.pocket.enabled" = lock-false;

      # Disable form auto-fill
      "browser.formfill.enable" = lock-false;

      # Disable search suggestions
      "browser.search.suggest.enabled" = lock-false;
      "browser.search.suggest.enabled.private" = lock-false;
      "browser.urlbar.suggest.searches" = lock-false;
      "browser.urlbar.showSearchSuggestionsFirst" = lock-false;

      # Disable activity stream feed
      "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
      "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
      "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
      "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
      "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
      "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;

      # Disable ads
      "browser.topsites.contile.enabled" = lock-false;
      "browser.newtabpage.activity-stream.showSponsored" = lock-false;
      "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;

      # Vertical tabs
      "sidebar.revamp" = lock-true;
    };
  };
in
{
  programs.firefox = {
    enable = true;

    # NOTE: Policies are defined using overrides instead of the policies
    # property because of an issue with the nixpkgs-firefox-darwin overlay.
    # See https://github.com/bandithedoge/nixpkgs-firefox-darwin/issues/7
    package = (
      pkgs.firefox-bin.overrideAttrs (prevAttrs: {
        postInstall = ''
          folder="$out/Applications/Firefox.app/Contents/Resources/distribution"
          mkdir -p "$folder"
          echo '${builtins.toJSON { policies = policies; }}' > "$folder/policies.json"
        '';
      })
    );

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
    };
  };
}
