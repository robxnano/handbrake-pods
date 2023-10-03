#!/bin/sh

# Builds binaries for all distributions. Warning: Will take a very long time.

if [ $(command -v podman) ]; then
  DOCKER=podman
else
  DOCKER=docker
  BUILDKIT_ENABLED=1
  export BUILDKIT_ENABLED
fi
export DOCKER


build ()
{
  $DOCKER build -o "_build/$1${2:+-$2}" "${1:+--from $1:${2:-latest}}" "${3:-$1}"
}

build almalinux 9 el && \
build rockylinux 8 el && \
build alpine && \
build archlinux && \
build centos stream8 && \
build clearlinux && \
build debian 12 && \
build fedora 38 && \
build opensuse/leap 15.4 opensuse && \
build opensuse/tumbleweed latest opensuse && \
build ubuntu 22.04 && \
build ubuntu 20.04 && \
echo "Complete!"
