{ lib, flakeInputs, nixpkgs, shells, versions, system, ... }:
let
  mkPythonShell = { shell, version }:
    system:
    let
      venvDir = "./env";
      pythonPackages = pkgs."python${version}Packages";
      postShellHook = ''
        PYTHONPATH=\$PWD/\${venvDir}/\${pythonPackages.python.sitePackages}/:\$PYTHONPATH
      '';

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowBroken = true;
          allowUnsupportedSystem = true;
        };
      };

      shellPackages = [ pythonPackages.python pythonPackages.venvShellHook ]
        ++ (if shell == "dev" then [
          pythonPackages.pylint
          pythonPackages.flake8
          pythonPackages.black
        ] else
          [ ]);

    in pkgs.mkShell {
      inherit venvDir;
      name = "pythonify-${shell}";
      packages = shellPackages;
      postShellHook = postShellHook;
    };

  shellVersionPermutations =
    lib.concatMap (shell: map (pythonVersion: pythonVersion // shell) versions)
    shells;
  permutedHosts = shellVersionPermutations;

  /* We have a list of sets.
     Map each element of the list applying the mkHost function to its elements and returning a set in the listToAttrs format
     builtins.listToAttrs on the result
  */
in builtins.listToAttrs (map (mapInput@{ shell, version, ... }: {
  name = shell + "-" + version;
  value = mkPythonShell mapInput system;
}) permutedHosts)
