{ pkgs, ... }:

{
  # Don't change this:
  home.stateVersion = "25.05";
  # Let home-manager install and manage itself
  programs.home-manager.enable = true;

  # Configure the basics
  home.username = "elias";
  home.homeDirectory = "/Users/elias";

  # Git
  programs.git = {
    enable = true;
    extraConfig = { init.defaultBranch = "main"; };
  };

  # Zed
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" ];

    userSettings = {
      auto_update = false;

      lsp = {
        nixd = {
          initialization_options = {
            formatting = { command = [ "nixfmt" ]; };
          };
        };
      };

      telemetry = {
        diagnostics = false;
        metrics = false;
      };
    };
  };

  # Packages
  home.packages = with pkgs; [
    coreutils
    curl
    wget
    ripgrep
    jq
    nmap
    hyperfine
    htop
    tree
    git
    gnupg
    openssh
    openssl
    p7zip
    tokei
    gh
    pandoc
    typst
    libreoffice-bin
    hunspell
    hunspellDicts.en_US
    hunspellDicts.sv_SE
    ffmpeg
    gimp-with-plugins
    inkscape-with-extensions
    zed-editor
    nixd
    nixfmt-rfc-style
  ];
}
