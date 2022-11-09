##############################################################
#                          MPICH base                        #
##############################################################

################################################
#                  Build base                  #
################################################
FROM alpine:3.16 as build-base

# Author info
LABEL org.opencontainers.image.authors="pikrog@github.com"

# Update system dependencies and install build base (i.a. GCC compiler)
RUN apk update && apk upgrade && apk add --no-cache build-base

################################################
# Compile and install in a temporary directory #
################################################
FROM build-base as install

# Install compile-time dependencies
RUN apk add --no-cache perl linux-headers

# Software version
ARG LIBFABRIC_VERSION="1.15.1"
ARG MPICH_VERSION="4.0.2"

# Software source links
ARG LIBFABRIC_SOURCE_LINK="https://github.com/ofiwg/libfabric/releases/download/v${LIBFABRIC_VERSION}/libfabric-${LIBFABRIC_VERSION}.tar.bz2"
ARG MPICH_SOURCE_LINK="https://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz"

# Make jobs are run parallelly to speed up the compilation process
# Adjust this parameter depending on the number of available CPU cores
ARG PARALLEL_MAKE_JOBS=12

# Compile in the temporary directory
WORKDIR /tmp

# libfabric provided with the mpich 4.0.2 source relies on deprecated pthread_yield() and cannot be compiled on Alpine (unresolved external symbol)
# Download the libfabric source and save it as libfabric.tarball
RUN wget -O libfabric.tarball "${LIBFABRIC_SOURCE_LINK}"

# Extract the archive and rename the source folder
RUN tar xf libfabric.tarball && mv libfabric-*/ libfabric

# Work with the libfabric source
WORKDIR /tmp/libfabric

# Configure libfabric with default options
RUN ./configure

# Compile and install libfabric
RUN make install -j "${PARALLEL_MAKE_JOBS}" DESTDIR=/tmp/install

# Go back to the temporary directory
WORKDIR /tmp

# Download the mpich source package
RUN wget -O mpich.tarball "${MPICH_SOURCE_LINK}"

# Extract the mpich archive and rename the source folder
RUN tar xf mpich.tarball && mv mpich-*/ mpich

# Work with the mpich source
WORKDIR /tmp/mpich

# Configure mpich: Disable Python and Fortran (F08 module), tell where the libfabric include and lib directories are located
RUN ./configure --disable-fortran --disable-f08 --disable-collalgo-tests --with-libfabric=/tmp/install/usr/local

# Compile and install mpich
RUN make install -j "${PARALLEL_MAKE_JOBS}" DESTDIR=/tmp/install

################################################
#     Install in the system (final stage)      #
################################################
FROM build-base

# Copy compiled dependencies into the final destination
COPY --from=install /tmp/install /