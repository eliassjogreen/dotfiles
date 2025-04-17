{ ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = {}

      -- Disable tab bar
      config.enable_tab_bar = false;

      -- Configure font
      config.font = wezterm.font 'Zed Plex Mono'

      -- Configure bindings
      keys = {
        -- Fix jump word left/right
        { key = "LeftArrow", mods = "OPT", action = wezterm.action { SendString = "\x1bb" } },
        { key = "RightArrow", mods = "OPT", action = wezterm.action { SendString = "\x1bf" } },
      };

      return config
    '';
  };
}
