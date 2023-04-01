# Documentation

## Purpose and motivation

The software we are ripping off (`X`) is built on top of a build system `Y`
(like Rake or CMake) with an embedded DSL which is also turing complete.
Therefore we will be using GNU make to ilustrate the absurdity `X`.

The build system `Y` in software `X` belongs to the Java ecosystem.

## Example project structure 

```
.
├── marr/
├── project-name/
│   ├── 01-dev/
│   │   ├── app-01/
│   └── 03-prod/
│       ├── app-01/
│       └── app-02/
├── Makefile
├── application-server.mk
```

* `marr/`: The marr framework (git submodule)
* `Makefile`: The entry point for gnu make
* `application-server.mk`: Project specific code to handle setup a sever
* `project-name/`: Directory structure which contains variables for the differen environments and servers.

### `Makefile`

The `Makefile` should include the framework and project specific makefiles.

```makefile
# Include the framework
include marr/*.mk

# Include project specific code
include *.mk

# Otherwise include files selectively
include application-server.mk
```

### Variables / Context

Variables can be stored in an arbitrary directory structure and sourced by a
shell.

The variables can assembled by the `context` parameter which use a glob pattern
for the directory structure.

## Example usage

Examples of how to use the tool to a feeling of the surface API.

### Run custom / adhoc command 

Connect to all servers in dev environment and execute `id; uname -a`.

```bash
make run-custom-cmd context='project-name/01-dev/*' cmd='id; uname -a'
```

* `context`: Context represents all of the servers and settings (\*sigh\* stupid name...)
* `cmd`: Shell command that gets executed on the server

### Install docker

```bash
make package-install-docker context='project-name/01-dev/app-*'
```
