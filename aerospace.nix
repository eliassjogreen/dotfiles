{ lib, pkgs, ... }:
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

      mode.main.binding = {
        # Moving windows
        ctrl-alt-left = "move left";
        ctrl-alt-down = "move down";
        ctrl-alt-up = "move up";
        ctrl-alt-right = "move right";

        # Toggle fullscreen
        ctrl-alt-enter = "fullscreen";

        # Toggle floating window
        ctrl-alt-p = "layout floating tiling";

        # Create a new window inheriting cwd
        ctrl-alt-n = ''
          exec-and-forget osascript -e '
          tell application "System Events" to tell (first process whose frontmost is true)
              click menu item "New Window" of menu "Shell" of menu bar 1
              set frontmost to true
          end tell
          '
        '';

        # Mode select
        ctrl-alt-period = "mode main";
        ctrl-alt-comma = "mode join";
      };

      mode.join.binding = {
        ctrl-alt-left = "join-with left";
        ctrl-alt-down = "join-with down";
        ctrl-alt-up = "join-with up";
        ctrl-alt-right = "join-with right";

        # Mode select
        ctrl-alt-period = "mode main";
        ctrl-alt-comma = "mode join";
      };
    };
  };
}
