#!/bin/bash
# vim: ai:ts=8:sw=8:noet
# This is script that runs goss tests _from inside the image_ so that it is multi-arch
# NOTE: since this runs from inside the image in Dockerfile's RUN step, take care to not pollute the image!
set -EeufCo pipefail
IFS=$'\t\n'

# safenet: bail out if we're (presumably) not inside the docker build process
if [[ "unset" == "${TARGETARCH:-unset}" ]]; then
	>&2 echo "Environment variable 'TARGETARCH' is unset: are we inside docker build? Failing."
	exit 42
fi
if [[ "unset" == "${TARGETOS:-unset}" ]]; then
	>&2 echo "Environment variable 'TARGETOS' is unset: are we inside docker build? Failing."
	exit 42
fi

# safenet: check that we map the goss binary from the builder image
if ! command -v "goss" >/dev/null 2>&1; then
	>&2 echo "Error! Unable to find the 'goss' command, can't run skkrty checks from within the image. Did you mount it properly?"
	exit 42
fi

# tests are mounted in Dockerfile
goss --gossfile /mnt/tests/integration/goss/gossfile.yml validate
