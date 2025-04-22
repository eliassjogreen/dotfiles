{ ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "git-firefly"
      "terraform"
      "toml"
    ];

    # This is the actual zed configuration
    userSettings = {
      auto_update = false;

      # Hide gitignored files
      project_panel = {
        hide_gitignore = true;
      };

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

        yaml-language-server = {
          settings = {
            yaml = {
              schemas = {
                "https://taskfile.dev/schema.json" = [
                  "Taskfile*.yml"
                  "Taskfile*.yaml"
                ];
              };
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
