{
  description = "A flake for pythonification";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, flake-utils, nixpkgs, ... }:

    flake-utils.lib.eachSystem [
      "x86_64-darwin"
      "aarch64-darwin"
      "x86_64-linux"
      "aarch64-linux"
    ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pythonPackages = pkgs.python312Packages;

        versions = [
          # Supported python versions
          { version = "311"; }
          { version = "312"; }
        ];

        venvDir = "./env";

        runPackages = with nixpkgs; [
          pythonPackages.venvShellHook
        ];

        devPackages = with nixpkgs;
          runPackages ++ [ pkgs.pylint pkgs.flake8 pkgs.black ];

        # This is to expose the venv in PYTHONPATH so that pylint can see venv packages
        postShellHook = ''
          PYTHONPATH=\$PWD/\${venvDir}/\${pythonPackages.python.sitePackages}/:\$PYTHONPATH
          # pip install -r requirements.txt
        '';

      in rec {
        runShell = pkgs.mkShell {
          inherit venvDir;
          name = "pythonify-run";
          packages = runPackages;
          postShellHook = postShellHook;
        };
        developmentShell = pkgs.mkShell {
          inherit venvDir;
          name = "pythonify-dev";
          packages = devPackages;
          postShellHook = postShellHook;
        };
        devShells.default = runShell;
        devShells.runShell = runShell;
      });
}
