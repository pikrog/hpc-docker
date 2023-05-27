# hpc-docker
Dockerized HPC cluster environment for convenient MPI application development.   
Inspired by [NLKNguyen/alpine-mpich](https://github.com/NLKNguyen/alpine-mpich).   
Provides dockerized MPICH and OpenMPI implementations available in both Debian and Alpine Linux. Example images:
- `pikrog/mpich:4.1.1-alpine` - MPICH 4.1.1 implementation installed in Alpine Linux,
- `pikrog/openmpi:4.1.5-bullseye` - OpenMPI 4.1.5 implementation installed in Debian Bullseye,
- `pikrog/mpich-node:1.0-alpine` - MPICH based cluster node in Alpine Linux,
- `pikrog/openmpi-node:1.0-bullseye` - OpenMPI based cluster node in Debian Bullseye.

Visit my [Docker Hub Page](https://hub.docker.com/u/pikrog) to discover all currently available variants.

# Use
You need to have an active [docker](https://docs.docker.com/get-docker/) service running

## Setting up a local development environment
Open terminal. Make a new directory for the environment. Name it whatever you want, then switch to it.

    $ mkdir hpc
    $ cd hpc
    
Prepare a working directory. This directory will contain compiled MPI applications and will be shared amongst containers through a bind mount. Name it `workdir`.

    $ mkdir workdir
    
The working directory can be conveniently used to place source code files to be compiled later.

Download one of the compose files from this repository and optionally modify the configuration according to your needs. For example, you may want to select different MPI implementation (OpenMPI, MPICH) or base Linux distribution (Alpine, Debian). This can be done by changing the image name provided in the `image` nodes.

    $ wget -O compose.yml "https://raw.githubusercontent.com/pikrog/mpich-docker/main/compose-mpich-alpine.yml"

Remember to rename this file to `compose.yml`. Otherwise you will need to specify the source compose file everytime when issuing `docker compose`:

    $ docker compose -f my-custom-compose.yml ...

Start the cluster in the background. Use `--scale worker=N` to adjust the number of worker nodes. In the example below, a cluster with four workers is created, which gives a total number of five nodes (including the master node).

    $ docker compose up -d --scale worker=4
    
Verify the cluster status.

    $ docker compose ps
    NAME              COMMAND                  SERVICE             STATUS              PORTS
    hpc-master-1      "run-cluster-node …"     master              running             0.0.0.0:22->22/tcp
    hpc-worker-1      "/usr/sbin/sshd -D"      worker              running
    hpc-worker-2      "/usr/sbin/sshd -D"      worker              running
    hpc-worker-3      "/usr/sbin/sshd -D"      worker              running
    hpc-worker-4      "/usr/sbin/sshd -D"      worker              running

Open bash in the master node container.

    $ docker compose exec -it --user user master /bin/sh
     
... or open a SSH connection to it. First, download the private key located in this repository (`master_Key`) or copy it from the master container.

    $ docker compose cp master:/home/user/.ssh/id_ed25519 ./private_key
    
Then you can use the private key as the identity file.

    $ ssh user@localhost -i private_key
    50939476b988:~/mpi$

## Single node environment
In case you don't actually need multiple workers but just want to use the MPI dependencies (like the toolchain or the process executor), you can start a single container and immediately work with it. The command below starts a single container with the MPICH 4.1.1 implementation in Alpine Linux.

    $ docker run -it --rm pikrog/mpich:4.1.1-alpine
    / #

Note that the `--rm` switch causes the container to be automatically removed after exit. Omit this switch if this behavior is unwanted.
Alternatively, pass `-v` to attach a bind mount pointing to the working directory.

    $ docker run -it --rm -v /host/path/to/workdir:/container/path/to/workdir pikrog/mpich:4.1.1-latest

## Configurable runtime environmental variables

|Variable name|Value type|Description|Default value|
|-|-|-|-|
|`HPC_AUTO_UPDATE_HOSTS`|switch|Run a background task that periodically updates the default host file. Meaningful only when the node works as a master.|`yes`|
|`HPC_HOSTNAMES`|string|Cluster nodes host names separated by whitespaces. This variable is used to automatically discover cluster hosts and update the default host file.|*none*|
|`HPC_NODE_MODE`|string|Cluster node mode. Possible values: `master`, `worker`.|`worker`|
|`HPC_ROOT_PASSWORD`|string|Set the root password.|*none*|
|`HPC_UPDATE_HOSTS_INTERVAL`|integer|Interval between automatic default host file updates.|`10`|
|`HPC_USER_PASSWORD`|string|Set the standard user password.|*none*|
|`HPC_SSH_ROOT_EXTERNAL_KEYS`|string|The value is a path to a directory containing SSH keys for the root. The contents of this directory will be copied directly into the root's SSH keys directory with appropriate permissions. All `*.pub` files will be interpreted as public keys and appended to the `authorized_keys` file.|*none*|
|`HPC_SSH_ROOT_DEFAULT_KEYS`|switch|Use the built-in SSH key pair for the standard user as the SSH root keys for authentication.|`no`|
|`HPC_SSH_ROOT_DEFAULT_PUBKEY`|switch|Leave built-in SSH public key for the root authentication. Meaningful only if `HPC_SSH_ROOT_DEFAULT_KEYS` is set enabled.|`yes`|
|`HPC_SSH_USER_EXTERNAL_KEYS`|string|Similar to `HPC_SSH_ROOT_EXTERNAL_KEYS` but for the standard user.|*none*|
|`HPC_SSH_USER_DEFAULT_KEYS`|switch|Leave built-in SSH key pair for the standard user authentication.|`yes`|
|`HPC_SSH_USER_DEFAULT_PUBKEY`|switch|Leave built-in SSH public key for the standard user authentication. Meaningful only if `HPC_SSH_USER_DEFAULT_KEYS` is set enabled.|`yes`|

*Note*: the **switch** value type means that the option associated with the variable will be switched on if the assigned value is one of: `yes`, `on`, `enable`, `enabled`, `true`, `1`.

## Advices for Swarm and production environments
TBA

# Building your applications

## Programming "on the fly"
TBA

## Embedding applications into a cluster node image
TBA

# Cluster node images details
TBA

# Building the images
## Basis
The images available at Docker Hub are built on a specific platform. When a base image is built, selected MPI libraries source codes are downloaded and compiled. This causes the environment to be configured specifically for the host platform. Therefore, certain optimizations may be enabled (e.g. AVX2) that are usually unavailable on older processors making provided images unusable on some computers. On the other hand, some people might want to get optimizations that the publicly available images do not have. Also, the online images are built for the `x86-64` architecture. Last but not least, all `Dockerfiles` can be adjusted according to users' needs (e.g. supplied with extra non-standard dependencies installed). In these cases, images have to be built from scratch.    
## Steps
Clone this repository.

    $ git clone https://github.com/pikrog/hpc-docker
    
Change directory to the distribution you want to use as a base. For example, if you want to run cluster nodes within Debian Linux, go to the `debian` directory.

    $ cd debian
    
Modify the `.env` file if needed. This file can be used to update the MPI implementation or Linux distribution version to the latest. One can also modify the distribution image name. This can be used to pick a different platform architecture, e.g. `arm64`. The `.env` file below will cause the images to be built for `arm64` with the MPICH libraries downgraded to 4.0.2.

    # This is only an example. It is not required to modify this file
    MPICH_VERSION="4.0.2"
    OPENMPI_VERSION="4.1.5"
    BASE_DISTRO="arm64v8/debian:bullseye-20230522"
    BASE_DISTRO_TAG="arm64-bullseye"
    VERSION_TAG="1.1"

To build a cluster node image, two commands need to be issued.

    # This is only a template
    $ docker compose build [MPI_IMPLEMENTATION]
    $ docker compose build [MPI_IMPEMENTATION]-node

For example, if you want to build a cluster embed with MPICH implementation, issue these commands:

    $ docker compose build mpich
    $ docker compose build mpich-node

It is possible to modify some build arguments when executing the build command and affect the building process as a result. The example below depicts how to select a different link from which the MPICH source code will be downloaded.

    $ docker compose build --build-arg MPICH_SOURCE_LINK=https://somewebiste.com/mpich.tar mpich

See the chapter below to discover available build arguments.

## Build arguments
### Base
|Argument|Description|Default value|
|-|-|-|
|`BASE_DISTRO`|Linux distribution to be used as the base for the image.|*varies, e.g. `alpine:3.18.0`*|
|`COMPILATION_PACKAGES`|Extra packages used only during the compilation process and not included in the final base image.|*varies, e.g. `perl wget`*|
|`EXTRA_BASE_PACKAGES`|Extra packages to be available in the base image.|*none*|
|`MAKE_PARALLEL_JOBS`|Number of parallel `make` jobs compiling sources. Use to speed up the compilation process.|`12`|

### MPICH Base
|Argument|Description|Default value|
|-|-|-|
|`MPICH_CONFIGURE_ARGS`|Arguments to pass to the `./configure` command for MPICH.|`--disable-fortran --disable-f08 --disable-collalgo-tests`|
|`MPICH_MAKE_ARGS`|Arguments to pass to the `make` command for MPICH.|`-j ${MAKE_PARALLEL_JOBS}`|
|`MPICH_SOURCE_LINK`|Link to a tarball archive containing MPICH source code.|`https://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz`|
|`MPICH_VERSION`|MPICH implementation version to download. Meaningful only if `MPICH_SOURCE_LINK` is left default.|*varies, e.g. `4.1.1`*|

### OpenMPI Base
|Argument|Description|Default value|
|-|-|-|
|`OPENMPI_CONFIGURE_ARGS`|Arguments to pass to the `./configure` command for OpenMPI.|*none*|
|`OPENMPI_MAKE_ARGS`|Arguments to pass to the `make` command for OpenMPI.|`-j ${MAKE_PARALLEL_JOBS}`|
|`OPENMPI_MAKE_INSTALL_ARGS`|Arguments to pass to the `make install` command for OpenMPI.|*none*|
|`OPENMPI_SOURCE_LINK`|Link to a tarball archive containing OpenMPI source code. `{major_version}` and `{version}` substrings are used to form a link based on `OPENMPI_VERSION`.|`https://download.open-mpi.org/release/open-mpi/v{major_version}/openmpi-{version}.tar.gz`|
|`OPENMPI_VERSION`|OpenMPI implementation version to download.|*varies, e.g. `4.1.5`*|

### MPI Node
|Argument|Description|Default value|
|-|-|-|
|`MPI_VERSION_TAG`|MPI implementation version tag of the base image from which the node image will be built.|*none*|
|`BASE_DISTRO_TAG`|Distribution tag of the base image from which the node image will be built.|*none*|
|`BASE_IMAGE_NAME`|Name of the base image from which the node image will be built.|*none*|
|`MPI_USER`|Name of the standard (non-root) user.|`user`|
|`MPI_DIRECTORY`|Path to the standard working directory containing i.a. MPI applications.|`/home/${MPI_USER}/mpi`|
|`DEFAULT_HOST_FILE`|Path to the default host file. This file is used by `mpirun` and `mpiexec` wrappers and is updated automatically by the background task.|`/etc/mpi/hosts`|
|`DEFAULT_HOST_FILE_ENV`|Name of the environmental variable that `mpirun` and `mpiexec` wrappers recognize. This name depends on particular MPI implementation.|`HYDRA_HOST_FILE` (MPICH)|

*Note*: `BASE_IMAGE_NAME`, `MPI_VERSION_TAG`, `BASE_DISTRO_TAG` form the full image name, e.g. for `BASE_IMAGE_NAME=pikrog/openmpi`, `MPI_VERSION_TAG=4.1.1`, `BASE_DISTRO_TAG=bullseye` they form `pikrog/openmpi:4.1.1-bullseye`.

## Versions

|Node Image Version Tag|MPICH Version|OpenMPI Version|
|-|-|-|
|1.0, 1.1|4.1.1|4.1.5|
