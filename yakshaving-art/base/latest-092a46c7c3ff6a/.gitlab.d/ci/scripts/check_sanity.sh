#!/bin/bash
# vim: ai:ts=8:sw=8:noet
# check.sh: run checks for this project, run from local machine or CI
# Usage: bash path/to/check.sh

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
	hadolint
	shellcheck
	trivy
COMMANDS
[ 0 -eq "${_cmds_missing}" ] || { exit 1; }

# Next, set up default variables if executing not on gitlab CI
if [[ "true" != "${GITLAB_CI:-false}" ]]; then
	# assume $root_dir/.gitlab.d/ci/scripts/check.sh location:
	CI_PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
fi

# Next, source whatever helpers we need
# shellcheck disable=SC1090
# source <(set +f; cat /usr/local/lib/functionarium/*) || { echo "Please install functionarium"; exit 1; }

# Next, set up all the traps
# [[ "true" == "${GITLAB_CI:-false}" ]] && trap ci_shred_secrets EXIT

# Finally, below this line is where all the actual functionality goes
#####################################################################

# run shellcheck on all the things
find "${CI_PROJECT_DIR}" \
	-type f \
	-name '*.sh' \
	-print0 \
	| xargs -0 -r shellcheck -x

# run hadolint on all Dockerfiles
find "${CI_PROJECT_DIR}" \
	-type f \
	-name 'Dockerfile*' \
	-print0 \
	| xargs -0 -r hadolint

# run yamllint on all yamls
find "${CI_PROJECT_DIR}" \
	-type f \
	-regex '.*\.ya?ml\(lint\)?' \
	-print0 \
	| xargs -0 -r yamllint --strict

# run custom linters on all Dockerfiles
LINTER_ERRORS=0

# check all the Dockerfiles for `~`s
while read -r -d $'\0'; do
	if grep -q '[^!]~' "${REPLY}"; then
		echo "Linter error: ${REPLY} contains '~', please replace with '\${HOME}'"
		(( LINTER_ERRORS++ ))
	fi
done< <(find "${CI_PROJECT_DIR}" \
		-type f \
		-name 'Dockerfile*' \
		-print0)

# finally, report if any
if [[ 0 -lt "${LINTER_ERRORS}" ]]; then
	echo "oh noes, ${LINTER_ERRORS} linter errors"
	exit 42
fi
