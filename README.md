# cpp_bash_utils

Some scripts I've been reusing in different C++ projects now put in one place.
Pass `--help` to any script for a list of all options.

**Requires**
 - _bash 4_

## Install Dependencies
`./scripts/install-dependencies.sh`

**Requires**
 - _conan package manager_
 - _./conanfile.txt_

## Build
`./scripts/build.sh`

**Requires**
 - _CMake_
 - _./CMakeLists.txt_

## Sandbox Environment
`./docker/run-command.sh`

**Requires**
 - _docker_
 - _./docker/my_build_environment.dockerfile_

  ### Misc
 - `./scripts/get-os.sh`
 - `./scripts/get-arch.sh`
 - `./scripts/get-compiler.sh`