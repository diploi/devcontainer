#!/usr/bin/env bash

set -eax

apt-get update -y
apt-get -y install --no-install-recommends direnv

mkdir -p /home/$_CONTAINER_USER/.local/share/direnv
chown 1000:1000 /home/$_CONTAINER_USER/.local/share/direnv

sed -i 's/^plugins=(\(.*\))/plugins=(\1 direnv)/' /home/$_CONTAINER_USER/.zshrc

cat <<EOF >> /home/$_CONTAINER_USER/.zshrc
export UV_LINK_MODE=copy
EOF