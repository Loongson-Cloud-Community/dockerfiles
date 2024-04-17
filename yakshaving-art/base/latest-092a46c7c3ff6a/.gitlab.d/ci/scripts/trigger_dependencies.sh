#!/bin/bash
# vim: ai:ts=8:sw=8:noet
# publish.sh: run publish step for this project, run from local machine or CI
# Usage: bash path/to/publish.sh

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
COMMANDS
[ 0 -eq "${_cmds_missing}" ] || { exit 1; }

# Next, source whatever helpers we need
# shellcheck disable=SC1090
# source <(set +f; cat /usr/local/lib/functionarium/*) || { echo "Please install functionarium"; exit 1; }

# Next, set up all the traps
# [[ "true" == "${GITLAB_CI:-false}" ]] && trap ci_shred_secrets EXIT

# Finally, below this line is where all the actual functionality goes
#####################################################################

# NOTE: CI_JOB_TOKEN for triggers is a EEP feature. On CE, you'll have to add
# triggers manually and use some sort of secret management solution to fetch
# those tokens from CI. GKMS/Vault works wonders for that :)
# TRIGGERS then could be a space separated string of <project>:<token>:<ref>
# for full control.
if [[ "true" != "${GITLAB_CI:-false}" ]]; then
	echo "Not on gitlab CI, hence not triggering dependend builds."
	exit 0
fi

# NOTE: if not on master/main/whatever, also don't trigger anything
if [[ "${CI_COMMIT_REF_SLUG:-undefined}" != "${CI_DEFAULT_BRANCH:-master}" ]]; then
	echo "Not on hamster, hence not triggering dependent builds."
	exit 0
fi

declare -a triggers_array
IFS=' ' read -r -a triggers_array <<< "${TRIGGERS:-}"
echo "Triggering dependent builds:"
for project in "${triggers_array[@]}"; do
	echo -n "	${project}: "
	# poor mans urlencode:
	project="${project//\//%2F}"	# /
	project="${project//\./%2E}"	# . (this is required too)
	curl -sSL -X POST --data "token=${CI_JOB_TOKEN}&ref=master" \
		"https://gitlab.com/api/v4/projects/${project}/trigger/pipeline" \
		| jq -r '.web_url'
done
