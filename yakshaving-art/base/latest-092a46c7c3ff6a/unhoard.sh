#!/bin/bash
# vim: ai:ts=8:sw=8:noet
# Unhoard: download binaries from hoardorr to proper location and according to arch
set -EeufCo pipefail
IFS=$'\t\n'

# all three are required, and are not envvars but rather arguments
# $1: binary name
# $2: os (TARGETOS), such as 'linux'
# $3: arch (TARGETARCH), such as 'amd64'

UNHOARD_DIR="${UNHOARD_DIR:-/usr/local/bin}"

wget -qqO "${UNHOARD_DIR}/${1}" "https://gitlab.com/yakshaving.art/hoardorr/-/jobs/artifacts/master/raw/${1}-${2}-${3}?job=hoard"

wget -qqO - "https://gitlab.com/yakshaving.art/hoardorr/-/jobs/artifacts/master/raw/${1}-${2}-$3.sha256?job=hoard" \
	| sed "s|  .*|  ${UNHOARD_DIR}/${1}|" \
	| sha256sum -c

# only if sha256sum match
chmod 0755 "${UNHOARD_DIR}/${1}"
