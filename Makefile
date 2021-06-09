.PHONY: all pull build test
#.SILENT:

# Should be the same in Dockerfile
REMOTE_URL?=https://github.com/metaborg/devenv
BRANCH?=code-completion

all: pull build #test


pull:
	if [ ! -d devenv-cc/.git ]; then git clone --recursive $(REMOTE_URL) devenv-cc; fi
	cd devenv-cc && \
	    git checkout $(BRANCH) && \
	    git pull --rebase && \
	    git submodule update --init --remote --recursive && \
	    ./repo update

build:
	cd devenv-cc && \
	    ./gradlew buildAll --stacktrace --info -x :spoofax3.core.root:statix.completions:test

test:
	cd devenv-cc && \
	    ./gradlew :spoofax3.core.root:statix.completions:test --stacktrace --info --continue

clean:
	cd devenv-cc && \
	    ./gradlew cleanAll --stacktrace --info
