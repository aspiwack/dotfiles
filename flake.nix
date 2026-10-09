{
  description = "Home Manager configuration of aspiwack";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    doom-emacs = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # The part of my configuration which, sadly, shouldn't be public
    # I'm trying to keep it to a minimum.
    # Sits in a sister directory so that updates are convenient. The setup isn't
    # perfect, I still need to manually update the flake input when I change the
    # private configuration.
    private = {
      url = git+file:../dotfiles-private;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.agenix.follows = "agenix";
    };
  };

  outputs = { self, nixpkgs, home-manager, doom-emacs, private, agenix }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    in {
      homeConfigurations."aspiwack" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./nixos.nix
          doom-emacs.homeModule
          agenix.homeManagerModules.default
          private.email
          private.irc
          ./services/irc.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
