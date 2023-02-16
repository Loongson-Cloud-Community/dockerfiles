#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-9001}

if [ "${RUN_AS_ROOT}" = "true" ]; then
  exec "$@"
fi

echo "Starting with UID : $USER_ID" 1>&2
# Do not create mail box.
/bin/sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd
# Don't pass "-m" to useradd if the home directory already exists (which can occur if it was volume mounted in) otherwise it will fail.
if [[ ! -d "/home/user" ]]; then
    /usr/sbin/useradd -m -U -s /bin/bash -u $USER_ID user
else
    /usr/sbin/useradd -U -s /bin/bash -u $USER_ID user
fi

export HOME=/home/user

if [ -n "$EXTRA_GROUP_ID"  ]; then
  echo "Adding user to additional GID : $EXTRA_GROUP_ID" 1>&2
  # Adding the group can fail if it already exists.
  if addgroup --gid $EXTRA_GROUP_ID group; then
    adduser user group
  else
    echo "Adding user to existing group instead" 1>&2
    adduser user `getent group $EXTRA_GROUP_ID | cut -d: -f1`
  fi
fi

if [ "$CGO_ENABLED" = "1" ]; then
  echo "CGO enabled, switching GOROOT to $GOCGO."
  export GOROOT=$GOCGO
  export PATH=$GOCGO/bin:$PATH
fi

exec /sbin/su-exec user "$@"
