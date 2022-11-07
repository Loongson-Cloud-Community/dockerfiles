#!/usr/bin/env bash
set -euo pipefail

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}


ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH=amd64
        ;;
    aarch64)
        ARCH=arm64
        ;;
esac

get_ctop() {
  VERSION=$(get_latest_release bcicen/ctop | sed -e 's/^v//')
  LINK="https://github.com/Loongson-Cloud-Community/ctop/releases/download/v0.7.7/ctop"
  wget "$LINK" -O /tmp/ctop && chmod +x /tmp/ctop
}

get_calicoctl() {
  VERSION=$(get_latest_release projectcalico/calicoctl)
  LINK="https://github.com/Loongson-Cloud-Community/calicoctl/releases/download/v3.18.0/calicoctl-linux-loongarch64"
  wget "$LINK" -O /tmp/calicoctl && chmod +x /tmp/calicoctl
}

get_termshark() {
  VERSION=$(get_latest_release gcla/termshark | sed -e 's/^v//')
  LINK="https://github.com/Loongson-Cloud-Community/termshark/releases/download/v2.4.0/termshark"
  wget "$LINK" -O /tmp/termshark && chmod +x /tmp/termshark 
}

get_ctop
get_calicoctl
get_termshark
