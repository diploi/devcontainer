#!/usr/bin/env bash

set -eax

apt-get update -y
apt-get -y install --no-install-recommends direnv

sed -i 's/^plugins=(\(.*\))/plugins=(\1 direnv)/' /home/$_CONTAINER_USER/.zshrc