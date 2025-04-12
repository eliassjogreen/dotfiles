{
  description = "My darwin system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Make nix clean up after itself
      nix.gc = {
        automatic = true;
        interval = { Weekday = 0; Hour = 0; Minute = 0; };
        options = "--delete-older-than 7d";
      };

      # Make sure there is always a bit of storage left
      nix.extraOptions = ''
        min-free = ${toString (10 * 1024 * 1024 * 1024)}
        max-free = ${toString (30 * 1024 * 1024 * 1024)}
      '';

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;

      # Configure system settings
      system.defaults = {
        # Opinionated dock
        dock.autohide = true;
        dock.mru-spaces = false;
        dock.minimize-to-application = true;
        dock.persistent-apps = [];
        dock.persistent-others = [];
        dock.show-recents = false;
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
      };

      # Enable touch id for sudo
      security.pam.services.sudo_local = {
        touchIdAuth = true;
        reattach = true;
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      # Configure nixpkgs to allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # Configure user
      users.users.elias = {
        name = "elias";
        home = "/Users/elias";
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .
    darwinConfigurations."datorn" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          # Configure home-manager
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.elias = import ./home.nix;
        }
      ];
    };
  };
}
