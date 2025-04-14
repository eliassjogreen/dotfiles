{ pkgs, ... }:
{
  # Don't change this:
  home.stateVersion = "25.05";
  # Let home-manager install and manage itself
  programs.home-manager.enable = true;

  # Configure the basics
  home.username = "elias";
  home.homeDirectory = "/Users/elias";

  imports = [
    /Users/elias/Code/eliassjogreen/dotfiles/git.nix
    /Users/elias/Code/eliassjogreen/dotfiles/zed.nix
    /Users/elias/Code/eliassjogreen/dotfiles/firefox.nix
  ];

  # Packages
  home.packages = with pkgs; [
    # General utilities and common dependencies
    coreutils
    curl
    wget
    ripgrep
    jq
    nmap
    htop
    tree
    gnupg
    openssh
    openssl
    p7zip
    tokei
    hyperfine

    # Git
    git
    gh

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

    # Code
    zed-editor
    nixd
    nixfmt-rfc-style

    # Firefox
    firefox-bin
  ];
}
