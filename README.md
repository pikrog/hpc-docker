# mpich-docker
Dockerized MPICH HPC cluster environment for convenient MPI application development.  
Inspired by [NLKNguyen/alpine-mpich](https://github.com/NLKNguyen/alpine-mpich). Adapted for the latest MPICH release (4.0.2).

# Use
You need to have an active [docker](https://docs.docker.com/get-docker/) service running

## Setting up a local development environment
Open terminal. Make a new directory for the environment. Name it whatever you want, then switch to it.

    $ mkdir mpich
    $ cd mpich
    
Prepare a working directory. This directory will contain compiled MPI applications and will be shared amongst containers through a bind mount. Name it `workdir`.

    $ mkdir workdir
    
The working directory can be conveniently used to place source code files to be compiled later.

Download the `compose.yml` file from this repository.

    $ wget "https://raw.githubusercontent.com/pikrog/mpich-docker/main/compose.yml"

Start the cluster in the background. Use `--scale worker=N` to adjust the number of worker nodes. In the example below, a cluster with four workers is created, which gives a total number of five nodes (including the master node).

    $ docker compose up -d --scale worker=4
    
Verify the cluster status.

    $ docker compose ps
    NAME                COMMAND                  SERVICE             STATUS              PORTS
    mpich-master-1      "run-cluster-master …"   master              running             0.0.0.0:22->22/tcp
    mpich-worker-1      "/usr/sbin/sshd -D"      worker              running
    mpich-worker-2      "/usr/sbin/sshd -D"      worker              running
    mpich-worker-3      "/usr/sbin/sshd -D"      worker              running
    mpich-worker-4      "/usr/sbin/sshd -D"      worker              running

Open bash in the master node container.

    $ docker exec -it mpich-master-1 /bin/ash
     
... or open a SSH connection to it. First, download the private key located in this repository (`mpi-master/default_private_ssh_key`) or copy it from the master container.

    $ docker cp mpich-master-1:/home/user/.ssh/master_key .
    
Then you can use the private key as the identity file.

    $ ssh user@localhost -i master_key
    50939476b988:~/mpi$

## Single node environment
In case you don't actually need multiple workers but just want to use the MPI dependencies (like the toolchain or the process executor), you can start a single container and immediately work with it.

    $ docker run -it --rm pikrog/mpi-node:0.3 /bin/ash
    / # cd /home/user/mpi
    /home/user/mpi #

Note that the `--rm` switch causes the container to be automatically removed after exit. Omit this switch if this behavior is unwanted.
Alternatively, pass `-v` to attach a bind mount pointing to the working directory.

    $ docker run -it --rm -v /host/path/to/workdir:/home/user/mpi pikrog/mpi-node:0.3 /bin/ash

## Building your first MPI application
TBA
