##############################################################
#                          MPICH base                        #
##############################################################

################################################
#                  Build base                  #
################################################

ARG BASE_DISTRO="debian:bullseye"
FROM ${BASE_DISTRO} as build-base

# Author info
LABEL org.opencontainers.image.authors="pikrog@github.com"

# Update system dependencies repository and install build essentials (i.a. GCC compiler) and wget utility
RUN apt-get update && apt-get install -y build-essential && apt-get clean

################################################
# Compile and install in a temporary directory #
################################################
FROM build-base as install

# Install compile-time dependencies
RUN apt-get install -y perl wget

# Software version
ARG OPENMPI_VERSION="4.1.5"

# Software source links
ARG OPENMPI_SOURCE_LINK="https://download.open-mpi.org/release/open-mpi/v{major_version}/openmpi-{version}.tar.gz"

# Make jobs are run parallelly to speed up the compilation process
# Adjust this parameter depending on the number of available CPU cores
ARG PARALLEL_MAKE_JOBS=12

# Compile in the temporary directory
WORKDIR /tmp

# Download the OpenMPI source package
# Format the URL with version numbers
RUN MAJOR_VERSION=$(echo "${OPENMPI_VERSION}" | sed -r "s/^([0-9]+\.[0-9]+).*/\1/") \
	&& URL=$(echo ${OPENMPI_SOURCE_LINK} | sed "s/{major_version}/${MAJOR_VERSION}/" | sed "s/{version}/${OPENMPI_VERSION}/") \
	&& wget -O openmpi.tarball "${URL}"

# Extract the OpenMPI archive and rename the source folder
RUN tar xf openmpi.tarball && mv openmpi-*/ openmpi

# Work with the OpenMPI source
WORKDIR /tmp/openmpi

# Configure OpenMPI
RUN ./configure 

# Compile and install OpenMPI
RUN DESTDIR=/tmp/install make -j "${PARALLEL_MAKE_JOBS}" all
RUN DESTDIR=/tmp/install make install

################################################
#     Install in the system (final stage)      #
################################################
FROM build-base

# Copy compiled dependencies into the final destination
COPY --from=install /tmp/install /