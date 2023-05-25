##############################################################
#                          MPICH base                        #
##############################################################

################################################
#                  Build base                  #
################################################

ARG BASE_DISTRO="alpine:3.17.3"
FROM ${BASE_DISTRO} as build-base

# Author info
LABEL org.opencontainers.image.authors="pikrog@github.com"

# Extra base packages to include in the final image
ARG EXTRA_BASE_PACKAGES=""

# Update apk lists and install build base (i.a. GCC compiler) and optionally extra packages
RUN apk update && apk add --no-cache build-base ${EXTRA_BASE_PACKAGES}

################################################
# Compile and install in a temporary directory #
################################################
FROM build-base as install

# Specify packages required to compile dependencies
ARG COMPILATION_PACKAGES="perl linux-headers"

# Install compile-time dependencies (if any)
RUN [ -n "${COMPILATION_PACKAGES}" ] && apk add --no-cache ${COMPILATION_PACKAGES}

# Software version
ARG OPENMPI_VERSION="4.1.5"

# Software source links
ARG OPENMPI_SOURCE_LINK="https://download.open-mpi.org/release/open-mpi/v{major_version}/openmpi-{version}.tar.gz"

# Make jobs are run parallelly to speed up the compilation process
# Adjust this parameter depending on the number of available CPU cores
ARG MAKE_PARALLEL_JOBS=12

# Configure and Make arguments
# Configure arguments. Defaults: standard configuration
ARG OPENMPI_CONFIGURE_ARGS=""

# Make arguments. Defaults: run parallel building jobs
ARG OPENMPI_MAKE_ARGS="-j ${MAKE_PARALLEL_JOBS}"
ARG OPENMPI_MAKE_INSTALL_ARGS=""

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
RUN ./configure ${OPENMPI_CONFIGURE_ARGS}

# Compile and install OpenMPI
RUN DESTDIR=/tmp/install make ${OPENMPI_MAKE_ARGS} all
RUN DESTDIR=/tmp/install make install ${OPENMPI_MAKE_INSTALL_ARGS}

################################################
#     Install in the system (final stage)      #
################################################
FROM build-base

# Copy compiled dependencies into the final destination
COPY --from=install /tmp/install /
