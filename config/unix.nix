{ config, pkgs, ... }:

# This file contains replacement for traditional Unix/Linux
# command-line utilities.
#
# I will note that we live in a word where many people are feeling
# both frustrated with the traditional Unix experience, and empowered
# by a new tool. Therefore we're seeing a lot of “a modern version of
# traditional utility X in Rust” (or sometimes, but less often, in
# go). Frankly there are quite a few which are pretty good.

{
  home.packages = [
    # Replacement for `find`
    pkgs.fd
    # Replacement for `sloccount`
    pkgs.tokei
    # Replacement for `ps`
    pkgs.procs
    # Replacement for `du`
    pkgs.duf
    # A variant of ssh which deals with disconnection and latency
    pkgs.mosh
    # Provides an interactive interface to systemctl
    pkgs.systemctl-tui
  ];

  # Replacement for `grep`. Particularly worthy because of how
  # ridiculously fast it is.
  programs.ripgrep.enable = true;

  # Replacement for `cd`, kind of. I don't find that it replaces
  # `cd` really. I use it to navigate between project, but use `cd`
  # within a project.
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };

  # Replacement for `cat`. Has syntax highlighting, does paging when
  # the text is too long (I also use it as a pager for man pages,
  # which gives them a little colour).
  programs.bat = {
    enable = true;
    config.theme = "Dracula";
  };

  # Replacement for `ls`. Installs an alias so that it's simply called
  # as `ls`. As a bonus, it provides an ls-like UX for Nushell, when
  # I'm interested in the visuals over the data.
  programs.eza.enable = true;

  # Interactive replacement for tree. It's almost a file manager.
  programs.broot = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

}
