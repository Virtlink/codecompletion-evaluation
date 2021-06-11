.PHONY: all all_completeness all_bench pull build completeness generate bench clean plot
#.SILENT:

# Should be the same in Dockerfile
REMOTE_URL?=https://github.com/metaborg/devenv
BRANCH?=code-completion
OUTPUT?=output/

all: all_bench
all_completeness: pull build completeness plot
all_bench: pull build generate bench #plot

pull:
	if [ ! -d devenv-cc/.git ]; then git clone --recursive $(REMOTE_URL) devenv-cc; fi
	cd devenv-cc && \
	    git checkout $(BRANCH) && \
	    git reset --hard HEAD && \
	    git pull --rebase --recurse-submodules && \
	    perl -i -pe 's!git@github.com:metaborg!https://github.com/metaborg!g' repo.properties && \
	    ./repo update

build:
	cd devenv-cc && \
	    ./gradlew buildAll --stacktrace --info -x :spoofax3.core.root:statix.completions:test && \
	    ./gradlew :spoofax3.core.root:statix.completions.bench:installDist

completeness:
	./devenv-cc/spoofax.pie/core/statix.completions.bench/build/install/statix.completions.bench/bin/statix.completions.bench \
	    completeness

generate:
	./devenv-cc/spoofax.pie/core/statix.completions.bench/build/install/statix.completions.bench/bin/statix.completions.bench \
	    generate --output=$(OUTPUT)/tiger-tests/

bench:
	./devenv-cc/spoofax.pie/core/statix.completions.bench/build/install/statix.completions.bench/bin/statix.completions.bench \
	    run --input=$(OUTPUT)/tiger-tests/ --file=$(OUTPUT)/results.csv

clean:
	cd devenv-cc && \
	    ./gradlew cleanAll --stacktrace --info

plot:
	python3 papers/oopsla21/datanalysis/main.py -p devenv-cc/ -o $(OUTPUT)