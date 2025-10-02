{ config, pkgs, ... }:

# This file contains the configuration of my terminal experience

{

  ### Terminal emulators
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "light:Catppuccin Latte,dark:Catppuccin Mocha";
    };
  };

  ### Terminal shells

  # Sets up the shells I use to have their configuration managed by
  # home manager.

  # Fish is my default shell. It mostly shine due to its great
  # completion mechanism.
  programs.fish.enable = true;

  # These days I use Bash mostly when I call `nix-shell`, which only
  # ever opens Bash.
  programs.bash = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
  };

  # I don't use much of Nushell, to be honest. But it's useful to have
  # it configured if I am to do a bit of data scraping from time to
  # time.
  #
  # Nushell is coming along quite nicely, honestly. Completion is
  # competitive with fish (Fish is still a little better, I'd say, for
  # instance it has the visual indicator for commands which don't
  # exist, the predictive completion is more powerful in Fish; overall
  # Fish feels smoother). Direnv works too. I could consider switching
  # to Nushell as my main shell.
  programs.nushell = {
    enable = true;
  };

  ### Theming

  # Starship is a terminal independent (well it supports a bunch of
  # terminals, not all of them, no eshell for instance, last time I
  # checked anyway, but that would be asking a lot) dynamic prompt
  # customisation. It is quite themable (my configuration is not
  # particularly vanilla), and can display a bunch of information such
  # as the programming environment that is set up, a summary of the
  # git status, …
  programs.starship =
    { enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      settings =
        { add_newline = false;
          line_break.disabled = true;
          character =
            # note: the double escaping is necessary for starship
            { success_symbol = "[\\$](bold green)";
              error_symbol = "[\\$](bold red)";
            };
          directory.truncation_symbol = "…/";
          directory.style="white";

          username.format = "[$user@]($style)";
          username.style_user = "blue";
          username.style_root = "red";
          hostname.format = "[$hostname$ssh_symbol]($style):";
          hostname.ssh_symbol = " 🌐";
          hostname.style = "blue";

          sudo.disabled = false;

          git_branch.format = "\\[[$symbol$branch]($style)\\] ";
          git_branch.style = "cyan";

          git_status.format = "([{$conflicted$deleted$renamed$modified$staged$ahead_behind}]($style) )";
          git_status.style = "red";

          cmd_duration.format = "[$duration]($style) ";
          cmd_duration.style = "yellow";

          ocaml.format = "\\([$symbol$version]($style)\\) ";
          ocaml.style = "yellow";

          aws.disabled = true;
        };
    };

  # Themes tmux (a terminal emulator and session manager in the
  # terminal).
  programs.tmux = {
    enable = true;
    clock24 = true;
    sensibleOnTop = true;
    # below is the default from sensible tmux, but it's otherwise
    # overrided by the configuration
    terminal = "screen-256color";
    plugins = [
      { plugin = pkgs.tmuxPlugins.power-theme;
        extraConfig = "set -g @tmux_power_theme 'redwine'";
      }
    ];
  };

  programs.tmate = {
    enable = true;
    # It's a little unfortunate that I can't use my Tmux configuration
    # on Tmate. This is because Tmate is a fork of Tmux, and isn't
    # caught up with the latest developments. Or so I understand. So
    # this is a bit of a silly configuration, but it's a decent
    # workaround.
    extraConfig = ''
      ## Make tmate's tmux invisible so that we can call tmux inside.

      # Note: I still need to call `set TMUX` (Fish) or `export TMUX=`
      # (bash) to be able to call a nested TMUX.

      # Reassign prefix to random nonsense not conflict with tmux
      set -g prefix C-]
      bind-key ] send-prefix

      # turn off status bar so tmate is invisible
      set -g status off

      # Fix timeout for escape key
      set -s escape-time 0
    '';
  };

  ### Customisation

  # Enables and themes the fzf fuzzy finder. Most importantly for this
  # file, maybe, set fzf integration # with terminals:
  #
  # - Improved history search (Ctrl+R)
  # - Find files (Ctrl+T)
  # - Cd to subdirectory (Alt+C)
  programs.fzf =
    { enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      defaultOptions = ["--layout=reverse" "--border" "--height=70%"];
      # Use fd to find files
      changeDirWidgetCommand = "fd --type d";
      defaultCommand = "fd --type file";
    };

  programs.nix-your-shell.enable = true;

}
