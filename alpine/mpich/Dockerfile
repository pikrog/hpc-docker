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

ARG COMPILATION_PACKAGES="perl linux-headers"

# Install compile-time dependencies (if any)
RUN [ -n "${COMPILATION_PACKAGES}" ] && apk add --no-cache ${COMPILATION_PACKAGES}

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
