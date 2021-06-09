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
 && rm -rf /var/lib/apt/lists/*

# Switch to bash
#SHELL ["/bin/bash", "-c"]

# Setup Git
RUN git config --global user.name "Daniel A. A. Pelsmaeker"
RUN git config --global user.email "647530+Virtlink@users.noreply.github.com"

# Copy files
COPY Makefile .
COPY papers/ ./papers/

# Install Python requirements
RUN pip3 install -r papers/oopsla21/datanalysis/requirements.txt

# Run
ENV REMOTE_URL?=https://github.com/metaborg/devenv
ENV BRANCH?=code-completion
ENV TARGET=all
ENTRYPOINT make $TARGET
