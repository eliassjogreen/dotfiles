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
      "wakatime"
      "sql"
      "jinja2"
      "astro"
    ];

    # This is the actual zed configuration
    userSettings = {
      auto_update = false;

      # Enable copilot
      edit_predictions = {
        mode = "subtle";
      };

      features = {
        edit_prediction_provider = "copilot";
      };

      # Configure the default assistant
      assistant = {
        enabled = true;
        version = "2";

        default_model = {
          provider = "anthropic";
          model = "claude-3-7-sonnet-latest";
        };

        editor_model = {
          provider = "anthropic";
          model = "claude-3-7-sonnet-latest";
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
