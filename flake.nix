{
  description = "Home Manager configuration of aspiwack";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty.url = "github:ghostty-org/ghostty";
    doom-emacs = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ghostty, doom-emacs }:
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
          { home.packages = [ghostty.packages.x86_64-linux.default]; }
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
