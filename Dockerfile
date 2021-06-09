FROM adoptopenjdk/openjdk11:jdk-11.0.11_0-debian

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
    python3 \
 && rm -rf /var/lib/apt/lists/*

# Switch to bash
SHELL ["/bin/bash", "-c"]

# Setup Git
RUN git config --global user.name "Daniel A. A. Pelsmaeker"
RUN git config --global user.email "647530+Virtlink@users.noreply.github.com"

# Copy files
COPY docker/Makefile .

# Run
ENV REMOTE_URL?=https://github.com/metaborg/devenv
ENV BRANCH?=code-completion
ENV TARGET=all
ENTRYPOINT make $TARGET
