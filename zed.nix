{ ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "git-firefly"
      "terraform"
      "toml"
      "deno"
      "dockerfile"
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

        # NOTE: Deno gets enabled on a per-project basis as it is a far more
        # uncommon runtime than Node.
        # TypeScript = {
        #   language_servers = [
        #     "deno"
        #     "!typescript-language-server"
        #     "!vtsls"
        #     "!eslint"
        #   ];
        #   formatter = "language_server";
        # };
        # TSX = {
        #   language_servers = [
        #     "deno"
        #     "!typescript-language-server"
        #     "!vtsls"
        #     "!eslint"
        #   ];
        #   formatter = "language_server";
        # };
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

        # NOTE: See note
        # deno = {
        #   settings = {
        #     deno = {
        #       enable = true;
        #     };
        #   };
        # };
      };

      # Disable telemetry
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
    };
  };
}
