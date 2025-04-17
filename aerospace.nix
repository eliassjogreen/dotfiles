{ ... }:
{
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
          run = "move-node-to-workspace W";
        }
        {
          "if" = {
            app-id = "dev.zed.Zed";
          };
          run = "move-node-to-workspace E";
        }
      ];

      mode.main.binding = {
        # Focusing windows
        alt-shift-left = "focus left";
        alt-shift-down = "focus down";
        alt-shift-up = "focus up";
        alt-shift-right = "focus right";

        # Moving windows
        ctrl-alt-left = "move left";
        ctrl-alt-down = "move down";
        ctrl-alt-up = "move up";
        ctrl-alt-right = "move right";

        # Toggle fullscreen
        ctrl-alt-enter = "fullscreen";

        # Select workspace
        alt-shift-q = "Q";
        alt-shift-w = "W";
        alt-shift-e = "E";

        # Toggle workspace
        alt-tab = "workspace-back-and-forth";

        # Create a new window from existing one using menu as to ensure we
        # inherit cwd for terminals.
        ctrl-alt-n = ''
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

        alt-shift-comma = "mode service";
      };

      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
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
}
