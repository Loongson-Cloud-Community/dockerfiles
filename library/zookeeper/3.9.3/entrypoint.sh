#!/bin/bash

if [[ ! -f "$ZOO_DATA_DIR/myid" ]]; then
    echo "${ZOO_MY_ID:-1}" > "$ZOO_DATA_DIR/myid"
fi

cd /opt/zooKeeper/bin
exec "$@"
