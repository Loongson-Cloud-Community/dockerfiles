#!/bin/bash
# vim: ai:ts=8:sw=8:noet
# build.sh: run build for this project, run from CI
# Usage: bash path/to/build.sh

# First, set up some healthy tensions about how this script should be used:
#   - exclusively bash. POSIX purists are invited to maintain their forks :)
#   - exclusively bash-4.4 or later.
#   - executing, not sourcing.
# This doesn't make it safe, but it makes it reasonable safe to tolerate it.
[ -n "${BASH_VERSION}" ] || { echo "Error: bash is required!" ; exit 1; }
# note: we can use [[ and || here and below
if [[ 44 -gt "${BASH_VERSINFO[0]}${BASH_VERSINFO[1]}" ]]; then
	# of course, assuming there is no v2.10 out there :)
	echo "Error: bash 4.4 or above is required!"
	exit 1
fi

if [[ "${0}" != "${BASH_SOURCE[0]}" ]]; then
	echo "Error: script ${BASH_SOURCE[0]} is not supported to be sourced!"
	return 1
fi

# Next, we're free to use bashisms, so lets set pretty strict defaults:
#  - exit on error (-e) (caveat lector)
#  - no unset variables (-u)
#  - no glob (-f)
#  - no clobber (-C)
#  - pipefail
# , propagate those to children with SHELLOPTS and set default IFS.
# Again, not ideal, but reasonably safe-ish.
set -eufCo pipefail
export SHELLOPTS
IFS=$'\t\n'

# Next, check required commands are in place, and fail fast if they are not
_cmds_missing=0
while read -r ; do
	[[ "${REPLY}" =~ ^\s*#.*$ ]] && continue	# convenient skip
	if ! command -v "${REPLY}" >/dev/null 2>&1; then
		echo "Error: please install '${REPLY}' command or use image that has it"
		_cmds_missing+=1
	fi
done <<-COMMANDS
	docker
	# shellcheck
COMMANDS
[ 0 -eq "${_cmds_missing}" ] || { exit 1; }

# Safenet: since this also pushes to registry, there's not much sense
# to run this locally We're assuming people can't yolo from local machines
# into the registry. If you need to change this, you're on your own.
if [[ "true" != "${GITLAB_CI:-false}" ]]; then
	>&2 echo "Not on CI, exiting!"
	exit 42
else
	# On gitlabCI, just login to registry
	echo "${CI_JOB_TOKEN}" | docker login -u gitlab-ci-token --password-stdin "${CI_REGISTRY}"
fi

# Next, source whatever helpers we need
# shellcheck disable=SC1090
# source <(set +f; cat /usr/local/lib/functionarium/*) || { echo "Please install functionarium"; exit 1; }

# Next, set up all the traps
# [[ "true" == "${GITLAB_CI:-false}" ]] && trap ci_shred_secrets EXIT

# Finally, below this line is where all the actual functionality goes
#####################################################################

if [[ ! -f "${CI_PROJECT_DIR:-.}/Dockerfile" ]]; then
	echo "Nothing to build, kthxbye!"
	exit 0
fi

# Finally, build image and push it to registry

# setup buildx
export DOCKER_CLI_EXPERIMENTAL=enabled
# NOTE: this is sometimes hangs on gitlab.com
# Therefore, we run it with timeout of 10s and just fail the pipeline on timeout
timeout -k 1 -v 20 docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
docker buildx create --use --name mahbilda

declare -a DOCKER_IMAGE_TAGS=(
	# gitlab's registry
	"--tag" "${CI_REGISTRY}/${CI_PROJECT_PATH}:${CI_COMMIT_REF_SLUG}"
)

# NOTE: if on master/main/whatever, we add :latest tag as well to gitlab's registry
# If you wanna publish to another registry on master, add it here
if [[ "${CI_COMMIT_REF_SLUG:-undefined}" == "${CI_DEFAULT_BRANCH:-master}" ]]; then
	DOCKER_IMAGE_TAGS+=(
		"--tag" "${CI_REGISTRY}/${CI_PROJECT_PATH}:latest"
	)
fi

# Copy bind-mounted binaries to build context
cp \
	"$(which goss)" \
	"$(which trivy)" \
	.

# build the image
# NOTE: see Dockerfile for tests that run _from within the image_
# NOTE: if those fail, the whole build will be aborted and nothing will be pushed to the registry
# NOTE: if you need more registries, just add them above

# shellcheck disable=SC2068
docker buildx build \
	--pull \
	--push \
	--platform "${MUCHOS_ARCHES// /,}" \
	${DOCKER_IMAGE_TAGS[@]} .


# At this point, if build didn't fail, then the tested image is published to the registry. So, logout
docker logout "${CI_REGISTRY}"
