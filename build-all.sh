#!/bin/sh

set -e

MPICH_VERSION="4.0.2"
MPI_CLUSTER_VERSION="0.3"

docker build -t "pikrog/mpich:${MPICH_VERSION}" --build-arg MPICH_VERSION="${MPICH_VERSION}" mpich/
docker build -t "pikrog/mpi-node:${MPI_CLUSTER_VERSION}" mpi-node/
docker build -t "pikrog/mpi-master:${MPI_CLUSTER_VERSION}" mpi-master/
