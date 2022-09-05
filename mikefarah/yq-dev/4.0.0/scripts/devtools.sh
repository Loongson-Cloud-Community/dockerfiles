#!/bin/sh
set -ex
GO111MODULE=on go get golang.org/x/tools/cmd/goimports
#wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.24.0
