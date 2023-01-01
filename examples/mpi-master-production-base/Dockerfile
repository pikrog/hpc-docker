##############################################################
#      MPI Cluster Master Production Base (custom keys)      #
##############################################################

FROM pikrog/mpi-master:0.3

# Allow users to provide their own SSH keys by extending this image
# Extra keys must be placed in the ./keys subdirectory
ONBUILD COPY --chown=${MPI_USER} --chmod=600 ["./keys/", "/home/${MPI_USER}/.ssh/keys/"]

# Work with the SSH keys
ONBUILD WORKDIR /home/${MPI_USER}/.ssh

ONBUILD RUN \
# Deauthorize default keys
	echo -n "" > authorized_keys \
# Authorize all user-provided keys
	&& \
		if [ "$(ls -A keys/)" ]; then \
			for key in keys/*; do \
				(cat "$key"; echo) >> authorized_keys; \
			done \
		fi
		
# Go back to the root directory
ONBUILD WORKDIR /

# Run the SSH server instead of bash
#ONBUILD CMD ["/usr/sbin/sshd", "-D"]

# Expose the SSH default port
#ONBUILD EXPOSE 22/tcp
