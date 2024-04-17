#!/bin/bash
# vim: ai:ts=8:sw=8:noet
# This is script that tests security _from inside the image_ so that it is multi-arch
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

# safenet: check that we map the trivy binary from the builder image
if ! command -v "trivy" >/dev/null 2>&1; then
	>&2 echo "Error! Unable to find the 'trivy' command, can't run skkrty checks from within the image. Did you mount it properly?"
	exit 42
fi

# trivy defaults
export TRIVY_QUIET="${TRIVY_QUIET:-true}"
export TRIVY_TIMEOUT="10m"
export TRIVY_IGNOREFILE='/.trivyignore'		# mounted in Dockerfile

# TODO: caching? For now, simply delete it to not pollute the image
trap "rm -rf /tmp/trivy" EXIT

trivy --cache-dir /tmp/trivy image \
	--download-db-only \
	--no-progress

# Check the rootfs (skipping files that were mounted into the container)
trivy --cache-dir /tmp/trivy rootfs \
	--skip-files "$(command -v trivy),$(command -v goss)" \
	--no-progress \
	--exit-code 1 \
	--severity CRITICAL \
	/

# Check the filesystem (TODO: is this dupe?)
trivy --cache-dir /tmp/trivy filesystem \
	--skip-files "$(command -v trivy),$(command -v goss)" \
	--no-progress \
	--exit-code 1 \
	--severity CRITICAL \
	/

# If no critical issues, output all
trivy --cache-dir /tmp/trivy rootfs \
	--skip-files "$(command -v trivy),$(command -v goss)" \
	--no-progress \
	--exit-code 0 \
	/
