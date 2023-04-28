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
     
... or open a SSH connection to it. First, download the private key located in this repository (`mpi-master/default_private_ssh_key`) or copy it from the master container.

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

# Building your applications

## Programming "on the fly"
TBA

## Embedding applications into a cluster node image
TBA

# Cluster node images details
TBA

## Versions

|Node Image Version Tag|MPICH Version|OpenMPI Version|
|-|-|-|
|1.0|4.1.1|4.1.5|
