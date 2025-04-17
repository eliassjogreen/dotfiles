{
  pkgs,
  lib,
  ...
}:
{
  # Don't change this:
  home.stateVersion = "25.05";
  # Let home-manager install and manage itself
  programs.home-manager.enable = true;

  # Configure the basics
  home.username = "elias";
  home.homeDirectory = "/Users/elias";

  imports = [
    ./git.nix
    ./zed.nix
    ./firefox.nix
    ./wezterm.nix
    ./aerospace.nix
  ];

  # Fix zsh bindings
  programs.zsh = {
    enable = true;
    initExtra = ''
      bindkey ";3C" forward-word
      bindkey ";3D" backward-word
    '';
  };

  # Packages
  home.packages = with pkgs; [
    # General utilities and common dependencies
    coreutils

    # Performance utilities
    hyperfine
    htop

    # File system utilities
    ripgrep
    jq
    tree
    ncdu
    p7zip
    tokei

    # Internet and networking utilities
    nmap
    curl
    wget
    gnupg
    openssh
    openssl
    netcat

    # Configuration utilities
    defaultbrowser
    duti

    # Docker, containers and virtualization
    colima
    docker
    docker-compose

    # Git
    git
    gh

    # TODO:
    # # Office
    # pandoc
    # typst
    # libreoffice-bin
    # hunspell
    # hunspellDicts.en_US
    # hunspellDicts.sv_SE
    # # Creative
    # ffmpeg
    # gimp-with-plugins
    # inkscape-with-extensions

    # Window manager
    aerospace

    # Code
    wezterm
    zed-editor
    nixd
    nixfmt-rfc-style

    # Firefox
    firefox-bin
  ];

  launchd.agents = {
    # Automatically start colima
    colima = {
      enable = true;
      config = {
        Program = lib.getExe pkgs.colima;
        RunAtLoad = true;
      };
    };
  };
}
