{ lib, pkgs, ... }:
let
  open_new_window = ''
    exec-and-forget osascript -e '
    tell application "System Events"
      tell (first process whose frontmost is true)
        -- Create a new window from the frontmost
        if name is "WezTerm" then
          click menu item "New Window" of menu "Shell" of menu bar 1
        else if name is "Firefox" then
          click menu item "New Window" of menu "File" of menu bar 1
        else if name is "Zed" then
          click menu item "New Window" of menu "File" of menu bar 1
        else
          -- Huh, an unrecognized application, lets try some common menus
          repeat with menuName in {"Shell", "File"}
            try
              click menu item "New Window" of menu menuName of menu bar 1
              exit repeat
            end try
          end repeat
        end if

        -- Bring the newly opened application to front
        set frontmost to true
      end tell
    end tell
    '
  '';
  center_window = ''
    exec-and-forget osascript -e '
    tell application "System Events" to tell (first process whose frontmost is true)
      click menu item "Center" of menu "Window" of menu bar 1
    end tell
    '
  '';
in
{
  # Enable jankyborders
  services.jankyborders = {
    enable = true;
    settings = {
      hidpi = "on";
      active_color = "0xffffffff";
      inactive_color = "0x00ffffff";
    };
  };

  programs.aerospace = {
    enable = true;

    userSettings = {
      start-at-login = true;

      gaps = {
        inner.horizontal = 8;
        inner.vertical = 8;
        outer.left = 8;
        outer.bottom = 8;
        outer.top = 8;
        outer.right = 8;
      };

      after-startup-command = [
        "exec-and-forget ${lib.getExe pkgs.jankyborders}"
      ];

      # Workspace:
      # "Q" - Terminal
      # "W" - Web
      # "E" - Editor

      on-window-detected = [
        {
          "if" = {
            app-id = "com.github.wez.wezterm";
          };
          run = "move-node-to-workspace Q";
        }
        {
          "if" = {
            app-id = "org.mozilla.firefox";
          };
          check-further-callbacks = true;
          run = "move-node-to-workspace W";
        }
        {
          "if" = {
            app-id = "org.mozilla.firefox";
            window-title-regex-substring = "Private Browsing";
          };
          run = "layout floating";
        }
        {
          "if" = {
            app-id = "dev.zed.Zed";
          };
          run = "move-node-to-workspace E";
        }
        {
          "if" = {
            app-id = "com.apple.systempreferences";
          };
          run = "layout floating";
        }
        {
          "if" = {
            app-id = "com.apple.finder";
          };
          run = "layout floating";
        }
        {
          "if" = {
            app-id = "com.apple.mail";
          };
          run = "layout floating";
        }
      ];

      mode.main.binding = {
        # Focusing windows
        ctrl-shift-left = "focus left";
        ctrl-shift-down = "focus down";
        ctrl-shift-up = "focus up";
        ctrl-shift-right = "focus right";

        # Moving windows
        ctrl-alt-left = "move left";
        ctrl-alt-down = "move down";
        ctrl-alt-up = "move up";
        ctrl-alt-right = "move right";

        # Toggle fullscreen
        ctrl-alt-enter = "fullscreen";

        # Select workspace
        alt-shift-q = "workspace Q";
        alt-shift-w = "workspace W";
        alt-shift-e = "workspace E";

        # Toggle workspace
        alt-shift-tab = "workspace-back-and-forth";

        # Create a new window from existing one using menu as to ensure we
        # inherit cwd for terminals.
        ctrl-alt-n = open_new_window;

        # Toggle "scratchpad"
        ctrl-alt-p = [
          "layout floating tiling"
          # TODO: Only do this if we are not floating. I may have to do some
          # applescript magic or wait for aerospace to support listing window
          # layouts
          center_window
        ];

        alt-shift-comma = "mode service";
      };

      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
        left = "resize width -50";
        right = "resize width +50";
        up = "resize height -50";
        down = "resize height +50";
        r = [
          "flatten-workspace-tree"
          "mode main"
        ];
        f = [
          "layout floating tiling"
          "mode main"
        ];
        backspace = [
          "close-all-windows-but-current"
          "mode main"
        ];
      };
    };
  };

  home.activation.aerospace = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.getExe pkgs.aerospace} reload-config
  '';
}
