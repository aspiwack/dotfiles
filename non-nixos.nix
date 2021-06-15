{ ... }:

{
  imports = [ ./common.nix ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "aspiwack";
  home.homeDirectory = "/home/aspiwack";

  targets.genericLinux.enable = true;
  
  ### Nix configuration
  home.file.".config/nix/managed.conf".source = ./nix.conf;

}