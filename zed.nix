{ ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" ];

    # This is the actual zed configuration
    userSettings = {
      auto_update = false;

      languages = {
        "Nix" = {
          language_servers = [
            "nixd"
            "!nil"
          ];
        };
      };

      lsp = {
        nixd = {
          initialization_options = {
            formatting = {
              command = [ "nixfmt" ];
            };
          };
        };
      };

      telemetry = {
        diagnostics = false;
        metrics = false;
      };
    };
  };
}
