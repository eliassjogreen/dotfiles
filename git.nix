{ ... }:
let
  gitignore = builtins.fetchGit {
    url = "https://github.com/github/gitignore.git";
    rev = "010b77ba772d5e99185701aba47d0de681a87e1c";
  };
in
{
  programs.git = {
    enable = true;

    # Enable some git options
    lfs.enable = true;
    diff-so-fancy.enable = true;

    ignores = [
      # Load global gitignore from githubs own list
      (builtins.readFile "${gitignore}/Global/macOS.gitignore")
      # Ignore direnv
      "/.envrc"
      ".direnv/"
    ];

    # Configure default user name and email
    userName = "Elias Sjögreen";
    userEmail = "eliassjogreen1@gmail.com";

    # Configure signing
    signing.key = "A80BDCE5B456BF24";
    signing.signByDefault = true;

    # Configure custom email per directory
    includes = [
      {
        condition = "hasconfig:remote.*.url:git@github.com:5monkeys/*";
        contents.user = {
          email = "elias@5monkeys.se";
          signingKey = "DD8281944190F57C";
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:5m/*";
        contents.user = {
          email = "elias@5monkeys.se";
          signingKey = "DD8281944190F57C";
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:FinnishRail/*";
        contents.user = {
          email = "elias@5monkeys.se";
          signingKey = "DD8281944190F57C";
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:dorunner/*";
        contents.user = {
          email = "elias@5monkeys.se";
          signingKey = "DD8281944190F57C";
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:mrfridayab/*";
        contents.user = {
          email = "elias@scalability.se";
          signingKey = "17F4437F2DF8B412";
        };
      }
    ];

    # Some useful aliases
    aliases = {
      undo = "reset HEAD~1 --mixed";
    };

    # Some sensible defaults
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };

  # Enable gh cli
  programs.gh.enable = true;
}
