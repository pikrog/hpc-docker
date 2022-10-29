##############################################################
#                     MPI Cluster Worker                     #
##############################################################

FROM pikrog/mpich:4.0.2

# Install SSH and dumb-init (for proper SSH process signal handling)
RUN apk add --no-cache openssh dumb-init

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

# Create a non-privileged passwordless user
# The default MPI user is named "user"
ARG MPI_USER="user"
ENV MPI_USER=${MPI_USER}
RUN adduser -D "${MPI_USER}" \
# Install usermod
	&& apk add --no-cache shadow \
# Unlock the user for SSH
	&& usermod -p "*" "${MPI_USER}" \
# Delete the unused package
	&& apk del shadow
	
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

# Generate a SSH key pair
RUN \
# Generate an ed25519 key pair (dont encrypt the private key)
# The private key will be automatically used by the SSH client during public key authentication (default IdentityFile config)
	ssh-keygen -t ed25519 -P "" -f id_ed25519 \
# Authorize the public key
	&& cat id_ed25519.pub >> authorized_keys \
# Only allow the owning MPI user to read/write their authorized_keys file
	&& chmod 600 authorized_keys \
# The directory itself should be executable but only for the owner
	&& chmod 700 . \
# Delete the unnecessary public key file
	&& rm id_ed25519.pub

# Restore workdir
WORKDIR /

# Switch back to root to run the SSH server
USER root

# Setup entrypoint
# Use dumb-init to allow proper signal forwarding
ENTRYPOINT ["dumb-init", "--"]

# Start the SSH server by default. Do not run it in the background
CMD ["/usr/sbin/sshd", "-D"]