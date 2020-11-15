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

  ### Configuration ###

  home.packages =
    let
      emacs-base = pkgs.emacs;
      emacs = (pkgs.emacsPackagesFor emacs-base).emacsWithPackages (epkgs: (with epkgs.melpaPackages; [vterm]));
    in
    [ emacs

      pkgs.ag
      pkgs.git
      # pkgs.darcs
      pkgs.graphviz
      pkgs.lorri
      pkgs.direnv
      pkgs.fzf

      pkgs.xdot
    ];

  programs.zoxide.enable = true;

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
