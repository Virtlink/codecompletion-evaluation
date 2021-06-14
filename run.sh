#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o noclobber
set -o nounset
set -o xtrace

# Get the script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
OUTPUT="${DIR}/output/"

docker image build -t codecompletion-eval ${DIR}
mkdir -p ${OUTPUT}
docker container run --privileged -it --rm \
  -v ${OUTPUT}:/home/output \
  -e OUTPUT=/home/output \
  codecompletion-eval \
  all
