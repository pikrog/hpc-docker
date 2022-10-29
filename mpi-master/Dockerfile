##############################################################
#                     MPI Cluster Master                     #
##############################################################

FROM pikrog/mpi-node:0.3

# Install dig for domain resolution
RUN apk add --no-cache bind-tools

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

# Deploy default SSH authentication keys. Only the MPI user can read/write them
COPY --chown=${MPI_USER} --chmod=600 ["./default_public_ssh_key", "/home/${MPI_USER}/.ssh/authorized_keys"]
COPY --chown=${MPI_USER} --chmod=600 ["./default_private_ssh_key", "/home/${MPI_USER}/.ssh/master_key"]

# Time between default host file updates (in seconds)
# The default value is 10 seconds
ARG UPDATE_HOSTS_INTERVAL="10"
ENV UPDATE_HOSTS_INTERVAL=${UPDATE_HOSTS_INTERVAL}

# Setup entrypoint
# This script runs a task periodically updating the hosts file in the background
# When the entrypoint script finishes, it executes the command passed to it - that is the SSH server by default
ENTRYPOINT ["run-cluster-master"]

# Entrypoint overrides the inherited command...
# Start the SSH server. Do not run it in the background
CMD ["/usr/sbin/sshd", "-D"]

# This is the default SSH port
EXPOSE 22/tcp