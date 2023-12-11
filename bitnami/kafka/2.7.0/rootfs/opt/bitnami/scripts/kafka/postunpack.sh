#!/bin/bash

# shellcheck disable=SC1091

# Load libraries
. /opt/bitnami/scripts/libkafka.sh
. /opt/bitnami/scripts/libfs.sh

# Load Kafka environment variables
eval "$(kafka_env)"

# Move server.properties from configtmp to config.
# Temporary solution until kafka tarball places server.properties into config.
mv "$KAFKA_BASE_DIR"/configtmp/* "$KAFKA_CONF_DIR"
rmdir "$KAFKA_BASE_DIR"/configtmp

# Ensure directories used by Kafka exist and have proper ownership and permissions
for dir in "$KAFKA_LOG_DIR" "$KAFKA_CONF_DIR" "$KAFKA_MOUNTED_CONF_DIR" "$KAFKA_VOLUME_DIR" "$KAFKA_DATA_DIR" "$KAFKA_INITSCRIPTS_DIR"; do
    ensure_dir_exists "$dir"
done
chmod -R g+rwX "$KAFKA_BASE_DIR" "$KAFKA_VOLUME_DIR" "$KAFKA_DATA_DIR" "$KAFKA_INITSCRIPTS_DIR"
