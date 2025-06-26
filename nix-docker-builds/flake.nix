{
  description = "A simple Go package";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-25.05";

  outputs =
    { self, nixpkgs }:
    let

      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # Thanks nix-darwin!
      system = "aarch64-linux";

      # Nixpkgs instantiated for supported system types.
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {

      bin = pkgs.buildGoModule {
        pname = "hello-server";
        inherit version;
        # In 'nix develop', we don't need a copy of the source tree
        # in the Nix store.
        src = ./.;

        # This hash locks the dependencies of this package. It is
        # necessary because of how Go requires network access to resolve
        # VCS.  See https://www.tweag.io/blog/2021-03-04-gomod2nix/ for
        # details. Normally one can build with a fake hash and rely on native Go
        # mechanisms to tell you what the hash should be or determine what
        # it should be "out-of-band" with other tooling (eg. gomod2nix).
        # To begin with it is recommended to set this, but one must
        # remember to bump this hash when your dependencies change.
        # vendorHash = pkgs.lib.fakeHash;

        vendorHash = null;
      };

      docker = pkgs.dockerTools.buildLayeredImage {
        name = "hello-server";
        tag = "latest";
        config.Cmd = "${self.bin}/bin/helloserver";
      };

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = self.bin;
    };
}
