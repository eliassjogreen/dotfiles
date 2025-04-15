{ pkgs, lib, ... }:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  # https://mozilla.github.io/policy-templates/
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

      # Disable ai
      "browser.ml.chat.enabled" = lock-false;
    };
  };
  # Certain preferences can't be configured through policies, for those it is
  # possible to instead use the `autoconf.js` script.
  # https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig
  autoconfig = ''
    // Enable vertical tabs
    lockPref("sidebar.revamp", true);
    lockPref("sidebar.revamp.round-content-area", true);
    lockPref("sidebar.verticalTabs", true);
    lockPref("sidebar.main.tools", "");
    lockPref("sidebar.expandOnHover", true);
    lockPref("sidebar.expandOnHoverMessage.dismissed", true);
    lockPref("sidebar.animation.expand-on-hover.duration-ms", 50);
    lockPref("sidebar.visibility", "expand-on-hover");
  '';
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
          resources="$out/Applications/Firefox.app/Contents/Resources"
          distribution="$resources/distribution"
          mkdir -p "$distribution" "$resources/defaults/pref"
          echo -e 'pref("general.config.filename", "firefox.cfg");\npref("general.config.obscure_value", 0);' > "$resources/defaults/pref/autoconfig.js"
          echo -e '// IMPORTANT: Managed through Nix\n${autoconfig}' > "$resources/firefox.cfg"
          echo '${builtins.toJSON { policies = policies; }}' > "$distribution/policies.json"
        '';
      })
    );

    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;

      extensions.packages = [
        # Privacy
        pkgs.nur.repos.rycee.firefox-addons.ublock-origin
        pkgs.nur.repos.rycee.firefox-addons.privacy-badger
        pkgs.nur.repos.ethancedwards8.firefox-addons.sponsorblock

        # Password manager
        pkgs.nur.repos.rycee.firefox-addons.bitwarden

        # Enhancements
        pkgs.nur.repos.rycee.firefox-addons.refined-github
      ];
    };
  };

  home.activation = {
    # Set Firefox as the default browser
    defaultBrowser = lib.hm.dag.entryAfter [ "installPackages" ] ''
      ${lib.getExe pkgs.defaultbrowser} firefox
    '';
  };
}
