#!/bin/bash
#
# Library for managing Bitnami components

# Constants
CACHE_ROOT="/tmp/bitnami/pkg/cache"
DOWNLOAD_URL="https://downloads.bitnami.com/files/stacksmith"

# Functions

########################
# Download and unpack a Bitnami package
# Globals:
#   OS_NAME
#   OS_ARCH
#   OS_FLAVOUR
# Arguments:
#   $1 - component's name
#   $2 - component's version
# Returns:
#   None
#########################
component_unpack() {
    local name="${1:?name is required}"
    local version="${2:?version is required}"
    local base_name="${3:?base_name is required}"
    local download_url="${4:?download_url is required}"
    local directory="/opt/bitnami"
    

    echo "Downloading $base_name package"
    if [ -f "${CACHE_ROOT}/${base_name}.tar.gz" ]; then
        echo "${CACHE_ROOT}/${base_name}.tar.gz already exists, skipping download."
        cp "${CACHE_ROOT}/${base_name}.tar.gz" .
        rm "${CACHE_ROOT}/${base_name}.tar.gz"
    else
	curl --remote-name --silent "${DOWNLOAD_URL}/${base_name}.tar.gz"
    fi
    tar --directory "${directory}" --extract --gunzip --file "${base_name}.tar.gz" --no-same-owner --strip-components=2 "${base_name}/files/"
    rm "${base_name}.tar.gz"
}
