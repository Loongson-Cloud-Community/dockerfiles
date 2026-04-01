#!/bin/bash

if [[ ! -f "$ZOO_DATA_DIR/myid" ]]; then
    echo "${ZOO_MY_ID:-1}" > "$ZOO_DATA_DIR/myid"
fi

if [[ -z $ZOO_SERVERS ]]; then
      ZOO_SERVERS="server.1=localhost:2888:3888;2181"
      echo ${ZOO_SERVERS} >> "$ZOO_CONF_DIR/zoo.cfg"
else
      IFS=\, read -a ZOO_SERVERS <<<"$ZOO_SERVERS"
      for server in ${!ZOO_SERVERS[@]}; do
            printf "\nserver.%i=%s:2888:3888;2181" "$((1 + $server))" "${ZOO_SERVERS[$server]}" >> "$ZOO_CONF_DIR/zoo.cfg"
      done
fi

cd /usr/local/zookeeper
exec "$@"
