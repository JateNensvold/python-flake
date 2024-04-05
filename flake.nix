{
  description = "A flake for pythonification";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = flakeInputs@{ self, flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachSystem [
      "x86_64-darwin"
      "aarch64-darwin"
      "x86_64-linux"
      "aarch64-linux"
    ] (system:
      let
        shells = [
          # python shell types
          { shell = "dev"; }
          { shell = "run"; }
        ];

        versions = [
          # Supported python versions
          { version = "310"; }
          {
            version = "311";
          }

          # { version = "312"; } # pylint does not compile for darwin on 312
        ];

        commonInherits = {
          inherit (nixpkgs) lib;
          inherit flakeInputs nixpkgs;
          inherit shells versions system;
        };

      in {
        devShells = import ./mkPythonShell.nix (commonInherits // { });

        # Test flake inputs
        tests = flakeInputs.nixtest.run ./.;
      });
}
