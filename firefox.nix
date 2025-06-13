{ pkgs, lib, ... }:
let
  lock-true = {
    Value = true;
    Status = "locked";
  };
  lock-false = {
    Value = false;
    Status = "locked";
  };
  # https://mozilla.github.io/policy-templates/
  policies = {
    DisableTelemetry = lock-true;
    DisableFirefoxStudies = lock-true;
    EnableTrackingProtection = {
      Value = lock-true;
      Locked = lock-true;
      Cryptomining = lock-true;
      Fingerprinting = lock-true;
    };
    DisablePocket = lock-true;
    DisableFirefoxAccounts = lock-true;
    DisableAccounts = lock-true;
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
  # possible to instead use the `autoconfig.js` script.
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

    // Enable tab groupos
    lockPref("browser.tabs.groups.enabled", true);
  '';
in
{
  programs.firefox = {
    enable = true;

    # NOTE: Policies are defined using overrides instead of the policies
    # property because of an issue with the nixpkgs-firefox-darwin overlay.
    # See https://github.com/bandithedoge/nixpkgs-firefox-darwin/issues/7
    package = (
      pkgs.firefox-bin.overrideAttrs (_: {
        # Theres a annoying-as-fuck bug with home-manager where the firefox
        # overlay fails to evaluate if bandithedoge/nixpkgs-firefox-darwin is
        # used. See:
        # https://github.com/nix-community/home-manager/issues/6955#issuecomment-2878146879
        override =
          _:
          pkgs.firefox-bin.overrideAttrs (_: {
            postInstall = ''
              resources="$out/Applications/Firefox.app/Contents/Resources"
              distribution="$resources/distribution"
              mkdir -p "$distribution" "$resources/defaults/pref"
              echo -e 'pref("general.config.filename", "firefox.cfg");\npref("general.config.obscure_value", 0);' > "$resources/defaults/pref/autoconfig.js"
              echo -e '// IMPORTANT: Managed through Nix\n${autoconfig}' > "$resources/firefox.cfg"
              echo '${builtins.toJSON { policies = policies; }}' > "$distribution/policies.json"
            '';
          });
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

        # Code
        (pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon rec {
          pname = "preact-devtools";
          version = "4.7.2";
          addonId = "devtools@marvinh.dev";
          url = "https://addons.mozilla.org/firefox/downloads/file/4269987/preact_devtools-${version}.xpi";
          sha256 = "sha256-iMalYgJGvZZfu7LhpMLjLT4rZRSHQ0v69E9ofxLDtK0=";
          meta = with pkgs.lib; {
            homepage = "https://github.com/preactjs/preact-devtools";
            description = "Browser extension that allows you to inspect a Preact component hierarchy, including props and state.";
            mozPermissions = [
              "<all_urls>"
              "scripting"
              "storage"
              "devtools"
              "clipboardWrite"
            ];
            license = licenses.mit;
            platforms = platforms.all;
          };
        })

        # Enhancements
        pkgs.nur.repos.rycee.firefox-addons.refined-github
        (pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon rec {
          pname = "besser-pinned-tabs";
          version = "1.5.1";
          addonId = "{bf5e830b-bda8-4a63-9b69-9bc67583efcd}";
          url = "https://addons.mozilla.org/firefox/downloads/file/4441431/besser_pinned_tabs-${version}.xpi";
          sha256 = "sha256-vI1QXZQ7J8t5sQmaZy+mFqL3r/gStHtvx4g6MmeUNzw=";
          meta = with pkgs.lib; {
            homepage = "https://github.com/RetroYogi/besser-pinned-tabs-firefox";
            description = "Protects pinned tabs by opening new domain links in new tabs";
            mozPermissions = [
              "<all_urls>"
              "tabs"
              "webNavigation"
              "storage"
            ];
            platforms = platforms.all;
          };
        })
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
