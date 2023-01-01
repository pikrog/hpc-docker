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
ARG MPICH_VERSION="4.0.2"

# Software source links
ARG MPICH_SOURCE_LINK="https://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz"

# Make jobs are run parallelly to speed up the compilation process
# Adjust this parameter depending on the number of available CPU cores
ARG PARALLEL_MAKE_JOBS=12

# Compile in the temporary directory
WORKDIR /tmp

# Download the mpich source package and save it as mpich.tarball
RUN wget -O mpich.tarball "${MPICH_SOURCE_LINK}"

# Extract the archive and rename the directory
RUN tar xf mpich.tarball && mv mpich-*/ mpich

# Go to the extracted directory
WORKDIR /tmp/mpich

# Configure mpich: Disable Python and Fortran (F08 module)
RUN ./configure --disable-fortran --disable-f08 --disable-collalgo-tests

# Compile and install
RUN make install -j "${PARALLEL_MAKE_JOBS}" DESTDIR=/tmp/install

################################################
#     Install in the system (final stage)      #
################################################
FROM build-base

# Copy compiled dependencies into the final destination
COPY --from=install /tmp/install /