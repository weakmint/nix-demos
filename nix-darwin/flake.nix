{
  description = "Demo nix-darwin system flake";

  inputs = {
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nix-darwin,
      nix-homebrew,
      ...
    }:
    let
      configuration =
        {
          pkgs,
          ...
        }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.vim
            pkgs.nixfmt-rfc-style
            pkgs.helix
            pkgs.nil
          ];

          homebrew = {
            enable = true;
            casks = [
              "iterm2"
              "waterfox"
            ];

          };

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          system.primaryUser = "amiller";

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          # enable the linux builder for cross-compilation
          nix.linux-builder.enable = true;
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#amiller-2525
      darwinConfigurations."amiller-2525" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;

              enableRosetta = false;

              user = "amiller";

              autoMigrate = true;
            };
          }
        ];
      };
    };
}
