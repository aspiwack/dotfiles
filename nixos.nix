{ ... }:

{
  imports = [ ./common.nix ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "aspiwack";
  home.homeDirectory = "/home/aspiwack";

  # For now, let me enable Dropbox on Nixos only, as my non-Nixos
  # computer have it enabled by more traditional means at the moment.
  services.dropbox.enable = true;
}
