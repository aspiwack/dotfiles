{ config, pkgs, ... }:

{
  ### Machine-specific preamble ###

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "aspiwack";
  home.homeDirectory = "/home/aspiwack";

  targets.genericLinux.enable = true;

  ### Home Manager self-configuration ###

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Note to self: pre-switch
  # $ echo $XDG_DATA_DIRS
  # /usr/share/gnome:/home/aspiwack/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share/:/usr/share/:/var/lib/snapd/desktop:/var/lib/snapd/desktop
  # See targets.genericLinux.extraXdgDataDirs

  ### Overlays ###

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  ### Configuration ###

  ## TODO: bat, fd, rg (and some rg packages for emacs,
  ## https://tldr.sh/,tokei (sloccount replacement), procs is a nice
  ## ps replacement)

  home.packages =
    [ pkgs.cachix

      pkgs.ag
      # pkgs.darcs
      pkgs.graphviz
      pkgs.lorri
      pkgs.direnv

      pkgs.xdot

      # Fonts
      pkgs.nerdfonts
    ];

  ### Fonts

  # For some reason, I had to manually perform some combination of
  # `{sudo,} fc-cache {-rs,-fv}` to make the Home-Manager-installed
  # fonts be picked up by Gnome Terminal. I suspect `fc-cache -r`
  # would have sufficed.
  fonts.fontconfig.enable = true;

  #### Shell/terminal

  programs.zoxide =
    { enable = true;
      enableFishIntegration = true;
    };

  programs.fzf =
    { enable = true;
      enableFishIntegration = true;
      defaultOptions = ["--layout=reverse" "--border" "--height=70%"];
    };

  programs.starship =
    { enable = true;
      enableFishIntegration = true;
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
          hostname.format = "[$hostname]($style):";
          hostname.style = "blue";

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

  programs.fish =
    { enable = true;
      functions =
        # TODO: I probably want to move all convenience functions to
        # scripts, so that they are cross-shell.
        { gitignoreio = "curl -sL https://www.gitignore.io/api/$argv";
        };
    };

  #### Git

  programs.git =
    { enable = true;
      userName = "Arnaud Spiwack";
      extraConfig =
        { pull.rebase = true;
        };

      # Aliases
      aliases =
        { ff = "pull --ff-only";
        };

      # Enable delta [https://github.com/dandavison/delta] as Git's
      # default diff viewer
      delta.enable = true;
    };

  #### Emacs

  programs.emacs =
    { enable = true;
      package = pkgs.emacsGcc;
      extraPackages = epkgs: (with epkgs.melpaPackages; [vterm]);
    };

  home.file.".emacs.d/init.el".source = emacs/bootstrap/init.el;
  home.file.".emacs.d/lisp/config.org" =
    { source = emacs/config.org;
      # The `config.el` produced by loading `config.org` in the Emacs
      # configuration, is not always refreshed when `config.org`
      # changes. So, let me delete the `config.el` file manually when
      # `config.org` is updated.
      onChange = ''
        rm -f $HOME/.emacs.d/lisp/config.el
      '';
    };

  ### Versioning ###

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";
}
