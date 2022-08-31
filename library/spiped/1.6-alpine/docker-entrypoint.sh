#!/bin/sh
set -e

case "$1" in
	-*) set -- spiped -k /spiped/key -F "$@" ;;
esac

exec "$@"
