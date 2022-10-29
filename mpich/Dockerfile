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

# Make jobs are run parallelly to speed up the compilation process
# Adjust this parameter depending on the number of available CPU cores
ARG PARALLEL_MAKE_JOBS=12

# Compile in the temporary directory
WORKDIR /tmp

# Download and extract the libfabric source package
# libfabric provided with the mpich 4.0.2 source relies on deprecated pthread_yield() and cannot be compiled on Alpine (unresolved external symbol)
RUN \
	wget "https://github.com/ofiwg/libfabric/releases/download/v${LIBFABRIC_VERSION}/libfabric-${LIBFABRIC_VERSION}.tar.bz2" \
	&& tar xjf "libfabric-${LIBFABRIC_VERSION}.tar.bz2"

# Configure, compile and install mpich in the temporary directory
RUN \
# Go to the extracted source directory
	cd "libfabric-${LIBFABRIC_VERSION}" \
# Configure with default options
	&& ./configure \
# Compile and install
	&& make install -j "${PARALLEL_MAKE_JOBS}" DESTDIR=/tmp/install

# Download and extract the mpich source package
RUN \
	wget "https://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz" \
	&& tar xzf "mpich-${MPICH_VERSION}.tar.gz"

# Configure, compile and install mpich in the temporary directory
RUN \
# Go to the extracted source directory
	cd "mpich-${MPICH_VERSION}" \
# Configure: Disable Python and Fortran (F08 module), tell where the libfabric include and lib directories are located
    && ./configure --disable-fortran --disable-f08 --disable-collalgo-tests --with-libfabric=/tmp/install/usr/local \
# Compile and install
	&& make install -j "${PARALLEL_MAKE_JOBS}" DESTDIR=/tmp/install

################################################
#     Install in the system (final stage)      #
################################################
FROM build-base

# Copy compiled dependencies into the final destination
COPY --from=install /tmp/install /