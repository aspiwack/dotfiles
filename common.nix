{ config, pkgs, ... }:

## # Installing steps
##
## Not everything can be done unfortunately automatically, here are
## things to do when installing on a new machines
##
## - [Only on non-nixos] Add `include managed.conf` to `~/.config/nix/nix.conf` (*after* the
##   first `home-manager switch`)


let
  my-emacs = pkgs.emacs-gtk;
  associator = name: d: pkgs.writeShellScript "associator-${name}" ''
      dict='${builtins.toJSON d}'
      if [ $# -eq 0 ]
      then echo $dict | jq -r 'keys | .[]'
      else echo $dict | jq -r ".[\"$1\"]" | xargs xargs
      fi
    '';
  scripts = rec {
      git-create = pkgs.writeShellScriptBin "git-create" ''
          name=$(basename $1 .git)
          mkdir $name
          cd $name
          hub clone $1 master
          cd master
      '';
      ghci-with = pkgs.writeShellScriptBin "ghciwith" ''
          nix-shell -p "haskellPackages.ghcWithPackages (pkgs: with pkgs; [$*])" --run ghci
      '';
      weather = pkgs.writeShellScriptBin "weather" ''
          [ -n $1 ] && arg="/$1"
          curl "wttr.in$arg"
      '';
      gitignoreio = pkgs.writeShellScriptBin "gitignoreio" ''
          curl -sL https://www.gitignore.io/api/$1;
      '';

      shortcuts = {
        screenshot = ''
          gnome-screenshot --area --file="/home/aspiwack/Downloads/Screenshot $(date --iso-8601=seconds).png"'';
      };
      shortcuts-script = associator "shortcuts" shortcuts;
      shortcuts-selector = pkgs.writeShellScriptBin "shortcuts-selector" ''
        rofi -modi Action:${shortcuts-script} -show Action
      '';
    };
in
{
  imports = [
    config/terminal.nix
    config/unix.nix
  ];

  ### Home Manager self-configuration ###

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Note to self: pre-switch
  # $ echo $XDG_DATA_DIRS
  # /usr/share/gnome:/home/aspiwack/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share/:/usr/share/:/var/lib/snapd/desktop:/var/lib/snapd/desktop
  # See targets.genericLinux.extraXdgDataDirs

  ### Overlays ###

  # Right now, Emacs from the main package has everything I
  # need. Except support for Wayland (the “pure GTK” build). Which
  # only exists for upcoming version 29. However, as of my last
  # testing, the master version of Emacs was not working very fine. In
  # particular LSP was extremely slow, which is not a productive
  # programming environment.
  #
  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball {
  #     url = https://github.com/nix-community/emacs  -overlay/archive/master.tar.gz;
  #   }))
  # ];

  ### Configuration ###

  home.packages =
    [ pkgs.cachix

      # pkgs.darcs
      pkgs.graphviz
      pkgs.lorri
      pkgs.progress

      pkgs.papis

      pkgs.xdot

      pkgs.nodePackages.emoj

      pkgs.chrysalis

      # Scripts
      scripts.git-create
      scripts.ghci-with
      scripts.weather
      scripts.gitignoreio
      scripts.shortcuts-selector

      # Fonts
      pkgs.nerdfonts
      pkgs.google-fonts
    ];

  ### Fonts

  # For some reason, I had to manually perform some combination of
  # `{sudo,} fc-cache {-rs,-fv}` to make the Home-Manager-installed
  # fonts be picked up by Gnome Terminal. I suspect `fc-cache -r`
  # would have sufficed.
  fonts.fontconfig.enable = true;

  #### Shell/terminal

  programs.navi = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  # TODO: I would like to move this to `terminal.nix`, but I need a
  # way to refer to Emacs from there
  home.sessionVariables = rec {
    EDITOR="${my-emacs}/bin/emacsclient -a '' -c";
    RLWRAP_EDITOR="${EDITOR} > /dev/null 2>&1";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };

  programs.jq.enable = true;

  programs.noti.enable = true;

  programs.htop.enable = true;
  programs.btop.enable = true;

  # Dmenu-type utility: launched with command line argument, pops up a
  # menu window to select options. I don't use much of it at all, I'm
  # sure I should.
  programs.rofi = {
    enable = true;
    theme = "DarkBlue";
  };

  # A tldr client. It's significantly faster than the original tldr
  # client (probably partly due to being written in Rust rather than
  # Node). I also appreciated the theming options, which let me remove
  # most of the bright green colours. And the fact that I could set
  # the database to automatically update is quite convenient too.
  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = false;
        use_pager = false;
      };
      style.example_text.rgb = {r = 128; g = 128; b = 128;};
      style.command_name.foreground = "red";
      style.example_code.foreground = "red";
      style.example_variable = {
        foreground = "blue";
        italic = true;
      };
      updates.auto_udpdate = "true";
    };
  };

  #### Development environment

  programs.git = {
    enable = true;
    userName = "Arnaud Spiwack";
    extraConfig =
      { pull.rebase = true;
      };
    lfs.enable = true;

    # Aliases
    aliases =
      { ff = "pull --ff-only";
        create = "!git-create";
      };

    # Enable difftastic [https://github.com/Wilfred/difftastic] as
    # Git's default diff viewer. It's a tree-sitter based tree diff
    # differ.
    difftastic =
      { enable = true;
        background = "dark";
      };
  };

  # Globally-configured ignored patterns
  home.file.".config/git/ignore".source = files/gitignore;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  #### Emacs

  programs.emacs =
    { enable = true;
      package = my-emacs;
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

  #### Papis

  home.file.".config/papis/config".source = files/papis.ini;

  #### Stack

  home.file.".stack/config.yaml".source = files/stack-config.yaml;

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
