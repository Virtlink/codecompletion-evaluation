.PHONY: all pull build test
#.SILENT:

REMOTE_URL?=https://github.com/metaborg/devenv

all: pull build test


pull:
	git clone --recursive $(REMOTE_URL) devenv-cc
	cd devenv-cc && \
	    ./repo update

build:
	cd devenv-cc && \
	    ./gradlew buildAll --stacktrace --info -x test

test:
	cd devenv-cc && \
	    ./gradlew testAll --stacktrace --info --continue

