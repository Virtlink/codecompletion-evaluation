.PHONY: all pull build test
#.SILENT:

# Should be the same in Dockerfile
REMOTE_URL?=https://github.com/metaborg/devenv
BRANCH?=code-completion
OUTPUT?=output/

all: pull build test plot

pull:
	if [ ! -d devenv-cc/.git ]; then git clone --recursive $(REMOTE_URL) devenv-cc; fi
	cd devenv-cc && \
	    git checkout $(BRANCH) && \
	    git reset --hard HEAD && \
	    git pull --rebase --recurse-submodules && \
		sed -i 's!git@github.com:metaborg!https://github.com/metaborg!g' repo.properties && \
	    ./repo update

build:
	cd devenv-cc && \
	    ./gradlew buildAll --stacktrace --info -x :spoofax3.core.root:statix.completions:test

test:
	cd devenv-cc && \
	    ./gradlew :spoofax3.core.root:statix.completions.bench:run

clean:
	cd devenv-cc && \
	    ./gradlew cleanAll --stacktrace --info

plot:
	python3 papers/oopsla21/datanalysis/main.py -p devenv-cc/ -o $(OUTPUT)