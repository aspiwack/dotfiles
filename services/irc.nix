{ config, lib, pkgs, ... }:

{
  # Runs an Emacs daemon as a service
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

  # Make a desktop app to launch a client which connects
  # to the daemon
  xdg.desktopEntries.irc-client = {
    name = "IRC";
    exec = "${config.programs.emacs.package}/bin/emacsclient -s irc -c";
    terminal = false;
  };

  # Read the logs
  xdg.desktopEntries.irc-logs = {
    name = "IRC logs";
    exec = ''${config.programs.nushell.package}/bin/nu -c "bat ...((ls ~/.local/share/circe/logs/*deduc*) | sort-by -r modified | get name)"'';
    terminal = true;
  };
}
