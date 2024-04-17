#!/bin/bash
# vim: ai:ts=8:sw=8:noet
# This is a wrapper around trivy invocation that checks _the repo_
set -EeufCo pipefail
IFS=$'\t\n'

# trivy defaults
export TRIVY_QUIET="${TRIVY_QUIET:-true}"

if [[ "true" == "${GITLAB_CI:-unset}" ]]; then
	# in case we decide to cache it on CI later
	export TRIVY_CACHE_DIR="${CI_PROJECT_DIR:-.}/.cache/trivy"
	export TRIVY_SKIP_DIRS="${CI_PROJECT_DIR:-.}/.cache"

	# output all the issues first
	trivy config --exit-code 0 .
	trivy fs --exit-code 0 .

	# fail pipeline on critical issues
	trivy config --exit-code 42 --severity CRITICAL .
	trivy fs --exit-code 43 --severity CRITICAL .
else
	# locally, we only care about simply running the checks
	trivy config .
	trivy fs .
fi
