#!/bin/sh

set -euo pipefail

if [ "$#" == "0" ]; then
    >&2 echo "Buildpack install dir required"
    exit 1
fi

BUILDPACK_INSTALL_DIR=$1

cp -r /opt/buildpack "$BUILDPACK_INSTALL_DIR"
