{ ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" ];

    # This is the actual zed configuration
    userSettings = {
      auto_update = false;
      restore_on_startup = "none";

      # Enable copilot
      show_completions_on_input = true;
      edit_predictions = {
        mode = "subtle";
      };

      # Configure the default assistant
      assistant = {
        enabled = true;
        version = "2";
        default_model = {
          provider = "copilot_chat";
          model = "gpt-4o";
        };
      };

      # Configure languages
      languages = {
        "Nix" = {
          language_servers = [
            "nixd"
            "!nil"
          ];
        };
      };

      # Configure LSPs
      lsp = {
        nixd = {
          initialization_options = {
            formatting = {
              command = [ "nixfmt" ];
            };
          };
        };
      };

      # Disable telemetry
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
    };
  };
}
