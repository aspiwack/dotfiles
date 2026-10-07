{ config, lib, pkgs, ... }:

{
  systemd.user.services.irc = {
  Unit = {
    Description = "Emacs IRC client";
    After = [ "graphical-session.target" ];
    PartOf = [ "graphical-session.target" ];
  };

  Service = {
    ExecStart =
      "${config.services.emacs.package}/bin/emacs"
      + " --fg-daemon=irc"
      + " --load %h/.config/emacs/irc.el";

    ExecStop =
      "${config.programs.emacs.package}/bin/emacsclient"
      + " -s irc"
      + " --eval '(kill-emacs)'";

    Restart = "on-failure";
  };

  Install.WantedBy = [ "graphical-session.target" ];
};
}
