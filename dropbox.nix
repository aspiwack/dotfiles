# Fixes Dropbox service, from
# https://github.com/nix-community/home-manager/pull/5923

{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.fixed-dropbox;
  baseDir = ".dropbox-hm";
  dropboxCmd = "${pkgs.dropbox}/bin/dropbox";
  homeBaseDir = "${config.home.homeDirectory}/${baseDir}";

in {
  meta.maintainers = [ hm.maintainers.tph5595 ];

  options = {
    services.fixed-dropbox = {
      enable = mkEnableOption "Dropbox daemon";

      path = mkOption {
        type = types.path;
        default = "${config.home.homeDirectory}/Dropbox";
        defaultText =
          literalExpression ''"''${config.home.homeDirectory}/Dropbox"'';
        apply = toString; # Prevent copies to Nix store.
        description = "Where to put the Dropbox directory.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.fixed-dropbox" pkgs
        lib.platforms.linux)
    ];

    home.packages = [ pkgs.dropbox ];

    systemd.user.services.fixed-dropbox = {
      Unit = { Description = "dropbox"; };

      Install = { WantedBy = [ "default.target" ]; };

      Service = {
        Environment = [ "HOME=${homeBaseDir}" ];

        PIDFile = "${homeBaseDir}/.dropbox/dropbox.pid";

        Restart = "on-failure";
        ProtectSystem = "full";
        Nice = 10;

        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStop = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = toString (pkgs.writeShellScript "dropbox-start" ''
          # ensure we have the dirs we need
          ${pkgs.coreutils}/bin/mkdir $VERBOSE_ARG -p \
            ${homeBaseDir}/{.dropbox,.dropbox-dist,Dropbox}
          ${pkgs.coreutils}/bin/touch ${homeBaseDir}/.dropbox-dist/VERSION

          # symlink them as needed
          if [[ ! -d ${config.home.homeDirectory}/.dropbox ]]; then
            ${pkgs.coreutils}/bin/ln $VERBOSE_ARG -s \
              ${homeBaseDir}/.dropbox ${config.home.homeDirectory}/.dropbox
          fi

          if [[ ! -d ${escapeShellArg cfg.path} ]]; then
            ${pkgs.coreutils}/bin/ln $VERBOSE_ARG -s \
              ${homeBaseDir}/Dropbox ${escapeShellArg cfg.path}
          fi

          ${dropboxCmd}
        '');
      };
    };
  };
}
