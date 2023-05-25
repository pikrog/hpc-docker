#!/bin/bash

set -e

SUPPORTED_DISTROS="debian alpine"
SUPPORTED_MPI_IMPLEMENTATIONS="mpich openmpi"

for distro in ${SUPPORTED_DISTROS}; do
	cd "${distro}"
	
	for mpi_impl in ${SUPPORTED_MPI_IMPLEMENTATIONS}; do
		docker compose build "${mpi_impl}"
		docker compose build "${mpi_impl}-node"
	done
	
	docker compose push
	cd -
done
