#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o noclobber
set -o nounset
set -o xtrace

# Get the script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker image build -t codecompletion-eval ${DIR}
docker container run --privileged -it --rm \
  -v ${DIR}/output-det:/home/output-det \
  -e OUTPUT=/home/output-det \
  codecompletion-eval \
  all