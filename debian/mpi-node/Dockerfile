##############################################################
#                      MPI Cluster Node                      #
##############################################################

ARG MPI_VERSION_TAG
ARG BASE_DISTRO_TAG
ARG BASE_IMAGE_NAME
FROM ${BASE_IMAGE_NAME}:${MPI_VERSION_TAG}-${BASE_DISTRO_TAG}

# Install SSH, dumb-init (for proper SSH process signal handling) and dig (for domain resolutoin)
RUN apt-get install -y --no-install-recommends ssh dumb-init dnsutils && apt-get clean

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
# Fix "Missing privilege separation directory" error
	&& mkdir -p /run/sshd

# Create a non-privileged passwordless user
# The default MPI user is named "user"
ARG MPI_USER="user"
ENV MPI_USER=${MPI_USER}
RUN adduser --disabled-password --gecos "" "${MPI_USER}"
	
# Path to the MPI directory (where MPI executables will be placed)
# The default path is ~/mpi
ARG MPI_DIRECTORY="/home/${MPI_USER}/mpi"
ENV MPI_DIRECTORY=${MPI_DIRECTORY}

# Switch to the MPI user to create their own files
USER ${MPI_USER}

# Prepare the main directory for MPI programs
RUN \
# Make the directory hierarchy
	mkdir -p "${MPI_DIRECTORY}" \
# After users login, this is their first working directory
	&& echo "cd \"${MPI_DIRECTORY}\"" >> ~/.profile
	
# Make and switch to the users .ssh directory. Both SSH server and client look for authorized keys in this directory by default
WORKDIR /home/${MPI_USER}/.ssh

# Deploy default SSH authentication keys. Only the MPI user can read/write them
COPY --chown=${MPI_USER} --chmod=600 ["./keys", "/home/${MPI_USER}/.ssh"]

# Node mode: worker/master
ENV NODE_MODE="worker"

##############################################################
#                        Master Config                       #
##############################################################

# Switch back to root
USER root

# Time between default host file updates (in seconds)
# The default value is 10 seconds
ARG UPDATE_HOSTS_INTERVAL="10"
ENV UPDATE_HOSTS_INTERVAL=${UPDATE_HOSTS_INTERVAL}

# Path to the default hosts file containing worker IP addresses
# If not provided, the default path is /etc/mpi/hosts
ARG DEFAULT_HOST_FILE="/etc/mpi/hosts"
# Hydra PM looks for a hosts file specified by this environmental variable (unless provided manually with -machinefile)
ENV HYDRA_HOST_FILE=${DEFAULT_HOST_FILE}

# Prepare the default hosts file
RUN \
# Create the directory hierarchy
	dir=$(dirname "${HYDRA_HOST_FILE}"); mkdir -p "$dir" \
# Create an empty file for storing hosts
	&& touch "${HYDRA_HOST_FILE}" \
# Adjust permissions (root: read-write, group and others: read-only)
	&& chmod 644 "${HYDRA_HOST_FILE}" \
# Permamently export the environmental variable
	&& echo "export HYDRA_HOST_FILE=\"${HYDRA_HOST_FILE}\"" >> /etc/profile

# Copy master startup and utility scripts
COPY --chmod=755 ./scripts /usr/local/bin/

##############################################################
#                        Finish Config                       #
##############################################################

# Restore workdir
WORKDIR /

# Setup entrypoint
# When the entrypoint script finishes, it executes the command passed to it - that is the SSH server by default
ENTRYPOINT ["run-cluster-node"]

# Start the SSH server. Verbose mode. Do not run it in the background
CMD ["/usr/sbin/sshd", "-D"]

# This is the default SSH port
EXPOSE 22/tcp
