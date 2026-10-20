# Version control configuration

{ config, lib, pkgs, ... }:

let
  scripts = {
    gitignoreio = pkgs.writeShellScriptBin "gitignoreio" ''
          curl -sL https://www.gitignore.io/api/$1;
      '';
  };
in

{

  home.packages = [
    # pkgs.darcs

    # Scripts
    scripts.gitignoreio

    # Diff pager (when receiving diffs so diffastic doesn't work, e.g. the `gh`
    # CLI).
    pkgs.diffnav

    # TUI for Github actions
    # It's ideally installed as an extension to gh, but I don't know how to do
    # so in the current setup. gh-dash is installed as an extension by its
    # home-manager module, though, so it must be possible.
    pkgs.gh-enhance
  ];

  ### Git

  programs.git = {
    enable = true;
    settings.user.name = "Arnaud Spiwack";
    settings =
      {
        pull.rebase = true;
        rerere.enabled = "true";
        rerere.autoupdate = "true";
        github.user = "aspiwack";
      };
    lfs.enable = true;

    # Aliases
    settings.alias =
      { ff = "pull --ff-only";
        create = "!git-create";
        # doesn't work because happens in a subshell so doesn't change
        # the directory
        # root = ''!cd "$(git rev-parse --show-toplevel)"'';
      };

  # Enable difftastic [https://github.com/Wilfred/difftastic] as
  # Git's default diff viewer. It's a tree-sitter based tree diff
  # differ.
  };
  programs.difftastic =
    { enable = true;
      git.enable = true;
      options.background = "dark";
    };
  
  # Globally-configured ignored patterns
  home.file.".config/git/ignore".source = ../files/gitignore;
  
  ### Github

  programs.gh = {
    enable = true;
    settings = {
      # -s is for side-by-side diffs. Omit for traditional stacked diffs
      pager = "delta -s";
      # Atlernative (adds a file tree navigator, which is enticing, but doesn't
      # feel quite polished enough yet):
      # pager = "diffnav";
    };
  };
  programs.gh-dash = {
    enable = true;
    settings = {
      # see gh's config above
      pager.diff = "delta -s";
      keybindings.prs = [
        {
          key = "T";
          command = "gh-enhance -R {{.RepoName}} {{.PrNumber}}";
        }
      ];
    };
  };

  # Gh sends pure diffs, I think so difftastic can't work for it. Instead, we
  # can use delta and configure it as a pager for gh.
  programs.delta.enable = true;
  
}
