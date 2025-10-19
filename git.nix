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

    ignores = [
      # Load global gitignore from githubs own list
      (builtins.readFile "${gitignore}/Global/macOS.gitignore")
      # Ignore direnv
      "/.envrc"
      ".direnv/"
      ".zed/"
    ];

    settings = {
      # Configure default user name and email
      user = {
        name = "Elias Sjögreen";
        email = "eliassjogreen1@gmail.com";
      };

      # Some useful aliases
      alias = {
        undo = "reset HEAD~1 --mixed";
        latest-release = "!git tag --sort=committerdate | tail -1 | sed -n 's|releases/\\(.*\\)|\\1|p'";
        next-release = "!if [[ \"$(git latest-release | cut -d '.' -f -2)\" == \"$(date '+%y.%m')\" ]]; then git latest-release | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g' ; else date '+%y.%m.1'; fi";
        changelog = "!git fetch origin -q && git --no-pager log --first-parent --pretty=\"- [ ] %h - %s (%an)\" \"origin/\${1:-main}..origin/\${2:-dev}\" #";
        release = "!gh pr create --base \${1:-main} --head \${2:-dev} --title \"$(git next-release)\" --body \"$(git changelog $1 $2)\" #";
        nuke = "!git clean -xfd && git submodule foreach --recursive git clean -xfd && git reset --hard && git submodule foreach --recursive git reset --hard && git submodule update --init --recursive";
      };

      # Some sensible defaults
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };

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
  };

  # Enable gh cli
  programs.gh.enable = true;
  # Fancy diffs
  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
  };
}
