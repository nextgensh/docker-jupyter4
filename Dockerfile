FROM ubuntu

USER root

# Install a few dependencies for build and compilations.
RUN apt-get update

# Install python and git dependencies
RUN apt-get install -y python3 python3-pip git sudo wget

# Install nodejs>18 which is needed by jupyter4 for building extensions.
ARG ARCH=linux-x64.tar.gz
ARG SUFF=linux-x64
WORKDIR /tmp/
RUN wget https://nodejs.org/dist/v18.16.0/node-v18.16.0-$ARCH
RUN tar -xvf node-v18.16.0-$ARCH && cd node-v18.16.0-$SUFF/ && cp -r bin/* /bin/ && cp -r include/* /usr/include/ && cp -r lib/* /lib/* && cp -r share/* /usr/share/

ARG LOCAL_USER=bob
ARG PRIV_CMDS='/bin/ch*,/bin/cat,/bin/gunzip,/bin/tar,/bin/mkdir,/bin/ps,/bin/mv,/bin/cp,/usr/bin/apt*,/usr/bin/pip*,/bin/yum'

# Create the user.
RUN useradd $LOCAL_USER --create-home

# Add the current user to sudoer, so she can run commands to install new packages if needed.
RUN usermod -aG sudo $LOCAL_USER && \
    echo "$LOCAL_USER ALL=NOPASSWD: $PRIV_CMDS" >> /etc/sudoers

USER $LOCAL_USER
WORKDIR /home/$LOCAL_USER

# Install jupyter-lab along with all the extensions and supporting python packages for AI/ML
COPY requirements.txt /tmp/requirements.txt

RUN pip install -r /tmp/requirements.txt
RUN pip install sensorfabric

# Set the path so we can find the installed binaries.
ENV PATH=$PATH:/home/$LOCAL_USER/.local/bin

# Rebuild jupyter lab with all the extensions we just installed.
RUN jupyter lab build

# Expose the running port we need to connect to.
EXPOSE 8088

RUN mkdir work
WORKDIR /home/$LOCAL_USER/work

# Copy the entry.sh file over.
COPY entry.sh /bin

ENTRYPOINT ["bash", "/bin/entry.sh"]
