{ ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = {}

      config.font = wezterm.font 'Zed Plex Mono'

      return config
    '';
  };
}
