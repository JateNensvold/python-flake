# Usage

## Options
The flake supports the following options for building a python environment

Shell types
- dev
- run

Python Versions
- 310
- 311

In any of the nix commands below simply concatinate the desired options above and run the setup commands
ex
```
... #<shell>-<version>
```

## Requirements

- nix(w/ flakes enables)
- direnv(optional)

## Setup

### Direnv
To create a python environment using direnv create a `.envrc` file at the root of your project

`.envrc`
```bash
use flake github:JateNensvold/python-flake/master#dev-311
```

Run
```bash
drenv allow
```

Now the python environment will be setup anytime you enter the directory containing `.envrc`

### Manual
To manually create a python environment execute the following command in the directory of your project

```bash
nix develop github:JateNensvold/python-flake/master#dev-311
```

To setup the environment again simply repeat the command above or run
```bash
source ./env/bin/activate
```

## Reset Environment
To reset the python environment or change the installed python version
simply remove the generate env directory and rerun the setup commands above

ex
```bash
rm -rf ./env
```
