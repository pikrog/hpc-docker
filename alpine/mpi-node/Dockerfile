##############################################################
#                      MPI Cluster Node                      #
##############################################################

ARG MPI_VERSION_TAG="4.1.1"
ARG BASE_DISTRO_TAG="alpine"
ARG BASE_IMAGE_NAME="pikrog/mpich"
FROM ${BASE_IMAGE_NAME}:${MPI_VERSION_TAG}-${BASE_DISTRO_TAG}

# Install SSH, dumb-init (for proper SSH process signal handling), dig (for domain resolution) and account management tools
RUN apk add --no-cache openssh dumb-init bind-tools shadow

##############################################################
#                        Common Config                       #
##############################################################

# Go to the SSH configuration directory
WORKDIR /etc/ssh

# Configure SSH
RUN \
# SSH Server config
# Allow public key authentication only
	echo "PasswordAuthentication no" >> sshd_config \
	&& echo "ChallengeResponseAuthentication no" >> sshd_config \
	&& echo "PubkeyAuthentication yes" >> sshd_config \
# SSH Client config
	&& echo "PubkeyAuthentication yes" >> ssh_config \
# Without this setting, mpiexec complains: "Host key verification failed"
# This is required unless we copy the host keys located in /etc/ssh to other nodes into ~/.ssh/know_hosts files
# But we dont have to bother about that in a local cluster environment
	&& echo "StrictHostKeyChecking no" >> ssh_config \
# Unfortunately, the standard openssh installation does not generate host keys by default. We do it manually
	&& ssh-keygen -A -P ""

##############################################################
#                        User Config                         #
##############################################################

# Create a non-privileged passwordless user
# The default MPI user is named "user"
ARG MPI_USER="user"
RUN adduser -D "${MPI_USER}" \
# Unlock the user for SSH, disallow password authentication
	&& usermod -p "*" "${MPI_USER}"

# Switch to the MPI user to create their own files
USER ${MPI_USER}

# Path to the MPI directory (where MPI executables will be placed)
# The default path is ~/mpi
ARG MPI_DIRECTORY="/home/${MPI_USER}/mpi"

# Prepare the main directory for MPI programs
RUN \
# Make the directory hierarchy
	mkdir -p "${MPI_DIRECTORY}" \
# After users login, this is their first working directory
	&& echo "cd \"${MPI_DIRECTORY}\"" >> ~/.profile

##############################################################
#                        Master Config                       #
##############################################################

# Switch back to root
USER root

# Path to the default hosts file containing worker IP addresses
# If not provided, the default path is /etc/mpi/hosts
ARG DEFAULT_HOST_FILE="/etc/mpi/hosts"

# Prepare the default hosts file
RUN \
# Create the directory hierarchy
	dir=$(dirname "${DEFAULT_HOST_FILE}"); mkdir -p "$dir" \
# Create an empty file for storing hosts
	&& touch "${DEFAULT_HOST_FILE}" \
# Allow modifying this file by everyone
	&& chmod 666 "${DEFAULT_HOST_FILE}"

##############################################################
#                        Finish Config                       #
##############################################################

# Restore workdir
WORKDIR /

# Hydra PM looks for a hosts file specified by this environmental variable (unless provided manually with -machinefile)
ARG DEFAULT_HOST_FILE_ENV="HYDRA_HOST_FILE"

# Permamently export some of the environmental variables
RUN \
	echo "export ${DEFAULT_HOST_FILE_ENV}=\"${DEFAULT_HOST_FILE}\"" >> /etc/profile \
	&& echo "export HPC_DEFAULT_HOST_FILE=\"${DEFAULT_HOST_FILE}\"" >> /etc/profile \
	&& echo "export HPC_MPI_USER=\"${MPI_USER}\"" >> /etc/profile \
	&& echo "export HPC_MPI_DIRECTORY=\"${MPI_USER}\"" >> /etc/profile

# Setup entrypoint
# Environmental variables used by the entrypoint and its subshell. These can be adjusted by a user when starting a container
ENV HPC_AUTO_UPDATE_HOSTS="yes"
ENV HPC_UPDATE_HOSTS_INTERVAL="10"
ENV HPC_NODE_MODE="worker"
ENV HPC_SSH_USER_DEFAULT_KEYS="yes"
ENV HPC_SSH_USER_DEFAULT_PUBKEY="yes"
ENV HPC_SSH_ROOT_DEFAULT_KEYS="no"
ENV HPC_SSH_ROOT_DEFAULT_PUBKEY="yes"

# The variables below aren't required to have default values:
# ENV HPC_HOSTNAMES
# ENV HPC_ROOT_PASSWORD
# ENV HPC_USER_PASSWORD
# ENV HPC_SSH_ROOT_EXTERNAL_KEYS
# ENV HPC_SSH_USER_EXTERNAL_KEYS

# These variables should be left as-is. Do not modify them when starting a container
ENV HPC_MPI_USER=${MPI_USER}
ENV HPC_MPI_DIRECTORY=${MPI_DIRECTORY}
ENV HPC_DEFAULT_HOST_FILE=${DEFAULT_HOST_FILE}
ENV ${DEFAULT_HOST_FILE_ENV}=${DEFAULT_HOST_FILE}

# Deploy default SSH authentication keys. Only the MPI user can read/write them
COPY --chown=${MPI_USER} --chmod=600 ["./keys", "/home/${MPI_USER}/.ssh"]

# Copy startup and utility scripts
COPY --chmod=755 ./scripts /usr/local/bin/

# When the entrypoint script finishes, it executes the command passed to it - that is the SSH server by default
ENTRYPOINT ["run-cluster-node"]

# Start the SSH server. Verbose mode. Do not run it in the background
CMD ["/usr/sbin/sshd", "-D"]

# This is the default SSH port
EXPOSE 22/tcp
