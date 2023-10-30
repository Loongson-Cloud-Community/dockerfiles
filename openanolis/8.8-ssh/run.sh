#!/bin/bash
/usr/sbin/sshd -D && tail -f /var/log/dnf.log
