#! /bin/sh
# Set the timezone of the container.
if [ "$SET_CONTAINER_TIMEZONE" = "true" ]; then
    echo ${CONTAINER_TIMEZONE} >/etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata
    echo "Container timezone set to: $CONTAINER_TIMEZONE"
else
    echo "Container timezone not modified"
fi

# Synchronize the time of the container.
ntpd -gq
service ntp start

# Set RMI server IP address in the Mule ESB wrapper configuration as to make JMX reachable from outside the container.
if [ -z "$MULE_EXTERNAL_IP" ]
then
    export MULE_EXTERNAL_IP=$(getent hosts $HOSTNAME | awk '{print $(NF - 1)}')
    echo "No external Mule ESB IP address set, using ${MULE_EXTERNAL_IP}"
else
    echo "Mule ESB external IP address set to $MULE_EXTERNAL_IP"
fi
sed -i -e"s|Djava.rmi.server.hostname=.*|Djava.rmi.server.hostname=${MULE_EXTERNAL_IP}|g" ${MULE_HOME}/conf/wrapper.conf

# Start Mule ESB.
# The Mule startup script will take care of launching Mule using the appropriate user.
# Mule is launched in the foreground and will thus be the main process of the container.
${MULE_HOME}/bin/mule console
