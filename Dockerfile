FROM adoptopenjdk:11-jdk-openj9-focal

WORKDIR /home/

# Install packages
RUN apt-get update \
 && apt-get install --no-install-recommends --yes \
    tini \
    bc \
	python3.9 python3-pip python3.9-dev \
    bash \
    sudo \
    wget \
    unzip \
    git \
    make \
    ssh \
    sed \
 && rm -rf /var/lib/apt/lists/*

# Switch to bash
SHELL ["/bin/bash", "-c"]

# Create the user
ARG GNAME=virtlink
ARG GID=1003
ARG UNAME=virtlink
ARG UID=1003
ARG UHOME=/home/virtlink/
RUN set -o errexit -o nounset \
 && groupadd --gid ${GID} ${GNAME} \
 && useradd --create-home --home "${UHOME}" --uid ${UID} --gid ${GID} "${UNAME}" \
 && mkdir -p "${UHOME}"
ENV HOME "${UHOME}"
USER ${UNAME}
WORKDIR ${UHOME}

# Setup Git
RUN git config --global user.name "Daniel A. A. Pelsmaeker" \
 && git config --global user.email "647530+Virtlink@users.noreply.github.com" \
 && mkdir -p ~/.ssh/ \
 && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# Env variables
ENV REMOTE_URL=https://github.com/metaborg/devenv
ENV BRANCH=code-completion
ENV OUTPUT=output/

# Clone repo
RUN git clone --recursive $REMOTE_URL devenv-cc \
 && cd devenv-cc \
 && git checkout $BRANCH \
 && sed -i 's!git@github.com:metaborg!https://github.com/metaborg!g' repo.properties \
 && ./repo update --info

# Build the project
RUN cd devenv-cc \
 && ./gradlew buildAll --stacktrace --info -x :spoofax3.core.root:statix.completions:test

# Copy files
COPY --chown=${UNAME} papers/ ./papers/

# Install Python requirements
RUN pip3 install -r papers/oopsla21/datanalysis/requirements.txt

# Copy more files
COPY --chown=${UNAME} Makefile .

# Run
ENTRYPOINT make
