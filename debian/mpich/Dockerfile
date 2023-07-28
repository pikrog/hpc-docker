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
ARG MPICH_VERSION="4.1.1"

# Software source links
ARG MPICH_SOURCE_LINK="https://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz"

# Download the mpich source package
RUN wget -O mpich.tarball "${MPICH_SOURCE_LINK}"

# Extract the mpich archive and rename the source folder
RUN tar xf mpich.tarball && mv mpich-*/ mpich

# Work with the mpich source
WORKDIR /tmp/mpich

# Make jobs are run parallelly to speed up the compilation process
# Adjust this parameter depending on the number of available CPU cores
ARG MAKE_PARALLEL_JOBS=12

# Configure arguments. Defaults: Disable Python and Fortran (F08 module)
ARG MPICH_CONFIGURE_ARGS="--disable-fortran --disable-f08 --disable-collalgo-tests"

# Configure mpich
RUN ./configure ${MPICH_CONFIGURE_ARGS}

# Make arguments. Defaults: run parallel building jobs
ARG MPICH_MAKE_ARGS="-j ${MAKE_PARALLEL_JOBS}"

# Compile and install mpich
RUN make install ${MPICH_MAKE_ARGS} DESTDIR=/tmp/install

################################################
#     Install in the system (final stage)      #
################################################
FROM build-base

# Copy compiled dependencies into the final destination
COPY --from=install /tmp/install /
