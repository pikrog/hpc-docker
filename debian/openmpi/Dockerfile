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

# Extra base packages to include in the final image
ARG EXTRA_BASE_PACKAGES=""

# Update apt lists and install build base (i.a. GCC compiler) and optionally extra packages
RUN apt-get update && apt-get install -y build-essential ${EXTRA_BASE_PACKAGES} && apt-get clean

################################################
# Compile and install in a temporary directory #
################################################
FROM build-base as install

# Specify packages required to compile dependencies
ARG COMPILATION_PACKAGES="perl wget"

# Install compile-time dependencies (if any)
RUN [ -n "${COMPILATION_PACKAGES}" ] && apt-get install -y ${COMPILATION_PACKAGES}

# Compile in the temporary directory
WORKDIR /tmp

# Software version
ARG OPENMPI_VERSION="4.1.5"

# Software source links
ARG OPENMPI_SOURCE_LINK="https://download.open-mpi.org/release/open-mpi/v{major_version}/openmpi-{version}.tar.gz"

# Download the OpenMPI source package
# Format the URL with version numbers
RUN MAJOR_VERSION=$(echo "${OPENMPI_VERSION}" | sed -r "s/^([0-9]+\.[0-9]+).*/\1/") \
	&& URL=$(echo ${OPENMPI_SOURCE_LINK} | sed "s/{major_version}/${MAJOR_VERSION}/" | sed "s/{version}/${OPENMPI_VERSION}/") \
	&& wget -O openmpi.tarball "${URL}"

# Extract the OpenMPI archive and rename the source folder
RUN tar xf openmpi.tarball && mv openmpi-*/ openmpi

# Work with the OpenMPI source
WORKDIR /tmp/openmpi

# Configure arguments. Defaults: standard configuration
ARG OPENMPI_CONFIGURE_ARGS=""

# Configure OpenMPI
RUN ./configure ${OPENMPI_CONFIGURE_ARGS}

# Compile and install OpenMPI
# Make arguments. Defaults: run parallel building jobs
# Make jobs are run parallelly to speed up the compilation process
# Adjust this parameter depending on the number of available CPU cores
ARG MAKE_PARALLEL_JOBS=12
ARG OPENMPI_MAKE_ARGS="-j ${MAKE_PARALLEL_JOBS}"
RUN DESTDIR=/tmp/install make ${OPENMPI_MAKE_ARGS} all

ARG OPENMPI_MAKE_INSTALL_ARGS=""
RUN DESTDIR=/tmp/install make install ${OPENMPI_MAKE_INSTALL_ARGS}

################################################
#     Install in the system (final stage)      #
################################################
FROM build-base

# Copy compiled dependencies into the final destination
COPY --from=install /tmp/install /
