#!/bin/bash
set -e
export NODE_VERSION=8

if [ ! -d "/tmp/nvm" ]; then
  rm -rf /tmp/nvm && git clone https://github.com/creationix/nvm.git /tmp/nvm && (cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`) && source /tmp/nvm/nvm.sh && nvm install $NODE_VERSION
fi

source /tmp/nvm/nvm.sh
gulp --min