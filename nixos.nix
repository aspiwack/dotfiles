{ pkgs, ... }:

let
  # See https://github.com/NixOS/nixpkgs/pull/277422
  # When merged I can remove this.
  fixed-dropbox = final: prev: {
    dropbox = prev.callPackage ./dropbox.nix {};
  };
in


{
  imports = [ ./common.nix ];

  nixpkgs.overlays = [ fixed-dropbox ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "aspiwack";
  home.homeDirectory = "/home/aspiwack";

  # For now, let me enable Dropbox on Nixos only, as my non-Nixos
  # computer have it enabled by more traditional means at the moment.
  services.dropbox.enable = true;

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      advanced-scene-switcher
      obs-livesplit-one
    ];
  };
}
