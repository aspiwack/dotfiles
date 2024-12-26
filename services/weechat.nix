{ config, pkgs, ... }:

{
  imports = [
  ];

  home.packages = [
    # I probably don't need this
    # pkgs.weechat
  ];


  systemd.user.services.persistent-irc = {
    Unit.Description = "Start a background IRC session";
    Install.WantedBy = [ "default.target" ];
    Service.Type= "oneshot";
    # Service.Environment = [
    #   ''"XDG_RUNTIME_DIR=/run/user/1000"''
    # ];
    Service.ExecStart = ''
      ${pkgs.tmux}/bin/tmux new-session -d -s irc "${pkgs.weechat}/bin/weechat"
    '';
      # ${pkgs.tmux}/bin/tmux new-session -d -s irc "${pkgs.weechat}/bin/weechat"
    Service.ExecStop = ''
      ${pkgs.tmux}/bin/tmux kill-session -t irc
    ''; 
    Service.RemainAfterExit = "yes";
  };
}
