#!/bin/bash
  
PACKAGES_FILE="packages.txt"

packages=$(cat "$PACKAGES_FILE" | tr '\n' ' ')
echo "Downloading $packages"

dnf install -y $packages
