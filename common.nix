{ config, pkgs, ... }:

## # Installing steps
##
## Not everything can be done unfortunately automatically, here are
## things to do when installing on a new machines
##
## - [Only on non-nixos] Add `include managed.conf` to `~/.config/nix/nix.conf` (*after* the
##   first `home-manager switch`)


let
  my-emacs = pkgs.emacs30-pgtk;
  scripts = rec {
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
    };
  overlays = {
    # Load extensions in Weechat
    weechat = self: super: {
      weechat = super.weechat.override {
        configure = {...}: {
          scripts = [
            super.weechatScripts.weechat-notify-send
          ];
        };
      };
    };
  };
in
{
  imports = [
    config/terminal.nix
    config/unix.nix
    services/weechat.nix
  ];

  ### Home Manager self-configuration ###

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Note to self: pre-switch
  # $ echo $XDG_DATA_DIRS
  # /usr/share/gnome:/home/aspiwack/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share/:/usr/share/:/var/lib/snapd/desktop:/var/lib/snapd/desktop
  # See targets.genericLinux.extraXdgDataDirs

  ### Overlays ###

  nixpkgs.overlays = [
    overlays.weechat
  ];

  ### Configuration ###

  home.packages =
    [ pkgs.cachix

      pkgs.aider-chat

      pkgs.evince
      pkgs.eog
      pkgs.nautilus
      pkgs.file-roller
      pkgs.vlc

      ## Images stuff
      pkgs.gimp
      pkgs.shotwell # photo manager

      ## Preview Markdown
      pkgs.go-grip

      ## Video stuff
      pkgs.kdePackages.kdenlive

      pkgs.libreoffice

      ## Sound stuff
      pkgs.qpwgraph

      # pkgs.darcs
      pkgs.graphviz
      pkgs.progress
      pkgs.jnv # interactive jq explorer

      pkgs.papis

      (pkgs.aspellWithDicts
          (dicts: with dicts; [ en en-computers en-science es fr ]))

      pkgs.nix-output-monitor
      pkgs.nix-tree

      pkgs.nodePackages.emoj

      pkgs.chrysalis

      pkgs.asdf-vm # package manager, used for steam plugins

      pkgs.deluge

      # Scripts
      scripts.ghci-with
      scripts.weather
      scripts.gitignoreio

      # Fonts
      pkgs.nerd-fonts.dejavu-sans-mono
      pkgs.nerd-fonts.ubuntu
      pkgs.nerd-fonts.ubuntu-mono
      pkgs.nerd-fonts.ubuntu-sans
      pkgs.google-fonts
      pkgs.libertine
    ];

  ### Fonts

  # For some reason, I had to manually perform some combination of
  # `{sudo,} fc-cache {-rs,-fv}` to make the Home-Manager-installed
  # fonts be picked up by Gnome Terminal. I suspect `fc-cache -r`
  # would have sufficed.
  fonts.fontconfig.enable = true;

  #### Desktop

  ##### Gnome settings
  programs.gnome-shell.enable = true;
  programs.gnome-shell.extensions = [
    { package = pkgs.gnomeExtensions.caffeine; }
    { package = pkgs.gnomeExtensions.night-theme-switcher; }
    { package = pkgs.gnomeExtensions.appindicator; }

  ];
  dconf.settings = {
    "org/gnome/mutter".experimental-features = ["scale-monitor-framebuffer"];
  };

  ##### Sound stuff
  services.easyeffects.enable = true;

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
    MANROFFOPT="-c"; # otherwise the above messes up the output of
                     # man. Don't know why. See
                     # https://github.com/sharkdp/bat/issues/2753#issuecomment-1792736679 .
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
      updates.auto_update = true;
    };
  };

  #### Development environment

  programs.git = {
    enable = true;
    userName = "Arnaud Spiwack";
    extraConfig =
      {
        pull.rebase = true;
        rerere.enabled = "true";
        rerere.autoupdate = "true";
        github.user = "aspiwack";
      };
    lfs.enable = true;

    # Aliases
    aliases =
      { ff = "pull --ff-only";
        create = "!git-create";
        # doesn't work because happens in a subshell so doesn't change
        # the directory
        # root = ''!cd "$(git rev-parse --show-toplevel)"'';
      };

    # Enable difftastic [https://github.com/Wilfred/difftastic] as
    # Git's default diff viewer. It's a tree-sitter based tree diff
    # differ.
    difftastic =
      { enable = true;
        background = "dark";
      };
  };
  programs.gh.enable = true;
  programs.gh-dash.enable = true;

  # Globally-configured ignored patterns
  home.file.".config/git/ignore".source = files/gitignore;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  #### Emacs

  programs.doom-emacs =
    let elastic-indent = epkgs:
          (epkgs.melpaBuild {
                    pname = "elastic-indent";
                    version = "9999snapshot1";
                    packageRequires = [ epkgs.dash ];
                    src = builtins.fetchTree {
                      type = "github";
                      owner = "jyp";
                      repo = "elastic-modes";
                      rev = "c577e8921a4d9bd77742729707152bc557fae3e2";
                    };
          });
        elastic-table = epkgs:
          (epkgs.melpaBuild {
                    pname = "elastic-indent";
                    version = "9999snapshot1";
                    packageRequires = [ epkgs.dash ];
                    src = builtins.fetchTree {
                      type = "github";
                      owner = "jyp";
                      repo = "elastic-modes";
                      rev = "c577e8921a4d9bd77742729707152bc557fae3e2";
                    };
          });
    in
    { enable = true;
      doomDir = ./emacs/files;
      doomLocalDir = "${config.xdg.configHome}/doom";
      emacs = my-emacs;
      extraPackages = epkgs: (with epkgs; [
        melpaPackages.vterm
        copilot
        (elastic-indent epkgs)
        (elastic-table epkgs)
      ]);
      tangleArgs = "--all config.org";
    };

  #### Papis

  home.file.".config/papis/config".source = files/papis.ini;

  #### Stack

  home.file.".stack/config.yaml".source = files/stack-config.yaml;

  #### Nix

  programs.nh.enable = true;

  ### Versioning ###

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}
