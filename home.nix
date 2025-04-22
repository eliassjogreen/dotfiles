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

  # Configure zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    envExtra = ''
      # Needed for certain rust projects
      export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"

      # Set default editor
      export EDITOR=zeditor
    '';

    initExtra = ''
      # Fix bindings
      bindkey ";3C" forward-word
      bindkey ";3D" backward-word

      # Replace cd with zoxide
      eval "$(zoxide init --cmd=cd zsh)"

      # Enable direnv
      eval "$(direnv hook zsh)"

      # Enable starship
      eval "$(starship init zsh)"
    '';

    shellAliases = {
      ls = "eza";
      ll = "ls -lah";
      cat = "bat";
      diff = "difftastic";
      code = "zeditor";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };
  };

  programs.starship = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # Packages
  home.packages = with pkgs; [
    # General utilities and common dependencies
    coreutils
    pkg-config

    # Privacy utilities
    apg
    age
    gnupg
    openssl

    # Performance utilities
    hyperfine
    htop
    samply

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
    openssh
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

    # Rust
    rustup
    cargo-binstall

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

    # Terminal and shell
    wezterm
    zsh
    starship
    direnv

    # Nicer tools
    eza
    zoxide
    bat
    difftastic

    # Code
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
