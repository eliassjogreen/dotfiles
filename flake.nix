{
  description = "My darwin system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-darwin is used to manage my system
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager is used to manage my user
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Needed for properly registering apps on darwin
    # NOTE: Hopefully solved within nix-darwin soon, see
    # https://github.com/nix-darwin/nix-darwin/pull/1396
    mac-app-util.url = "github:hraban/mac-app-util/link-contents";
    mac-app-util.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Do I want homebrew?
    # nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # nix-homebrew.inputs.nixpkgs.follows = "nixpkgs";

    # Firefox?
    firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    firefox-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Firefox addons
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      mac-app-util,
      firefox-darwin,
      firefox-addons,
      ...
    }@inputs:
    let
      nix =
        { ... }:
        {
          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Make nix clean up after itself
          nix.gc = {
            automatic = true;
            interval = {
              Weekday = 0;
              Hour = 0;
              Minute = 0;
            };
            options = "--delete-older-than 7d";
          };

          # Make sure there is always a bit of storage left
          nix.extraOptions = ''
            min-free = ${toString (10 * 1024 * 1024 * 1024)}
            max-free = ${toString (30 * 1024 * 1024 * 1024)}
          '';
        };
      darwin =
        { ... }:
        {
          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;
          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # Configure user
          users.users.elias = {
            name = "elias";
            home = "/Users/elias";
          };

          # Configure system settings
          system.defaults = {
            # Opinionated dock
            dock.autohide = true;
            dock.mru-spaces = false;
            dock.minimize-to-application = true;
            dock.persistent-apps = [ ];
            dock.persistent-others = [ ];
            dock.show-recents = false;
            dock.static-only = true;
            dock.tilesize = 32;

            # Sensible config for finder
            finder.AppleShowAllExtensions = true;
            finder.AppleShowAllFiles = true;
            finder.FXDefaultSearchScope = "SCcf";
            finder.QuitMenuItem = true;
            finder.ShowPathbar = true;
            finder.ShowStatusBar = true;

            # Disable annoying fn button action
            hitoolbox.AppleFnUsageType = "Do Nothing";

            # No need for a guest login
            loginwindow.GuestEnabled = false;

            # Put screenshots in a sensible place
            screencapture.location = "~/Pictures/Screenshots";

            # Change the scroll direction
            NSGlobalDomain."com.apple.swipescrolldirection" = false;

            # Fast key repeats
            NSGlobalDomain.KeyRepeat = 2;
            NSGlobalDomain.InitialKeyRepeat = 15;
            NSGlobalDomain.ApplePressAndHoldEnabled = false;

            # Disable automatic helpers
            NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
            NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
            NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
            NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
            NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
            NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
          };

          system.activationScripts.postUserActivation.text = ''
            # Immediately activate any changed settings
            /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
          '';

          # Enable touch id for sudo
          security.pam.services.sudo_local = {
            touchIdAuth = true;
            reattach = true;
          };

          # Set the default browser to firefox
          # defaultbrowser firefox

          # Enable alternative shell support in nix-darwin.
          programs.zsh.enable = true;

          # TODO: If I need homebrew
          # homebrew = {
          #   enable = true;
          #   onActivation.cleanup = "uninstall";
          #   onActivation.upgrade = true;
          # };
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .
      darwinConfigurations."datorn" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
          overlays = [ firefox-darwin.overlay ];
        };

        specialArgs = { inherit inputs; };
        modules = [
          nix
          darwin
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          {
            # Configure home-manager
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.sharedModules = [ mac-app-util.homeManagerModules.default ];

            # Configure my user
            home-manager.users.elias = import ./home.nix;
          }
        ];
      };
    };
}
