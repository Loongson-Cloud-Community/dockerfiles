#!/bin/sh
umask 0077
dd if=/dev/urandom bs=32 count=1 of=/spiped/key/spiped-keyfile
