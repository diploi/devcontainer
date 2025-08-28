#!/usr/bin/env bash

set -eax

sudo -iu $_REMOTE_USER <<EOF
    curl -sfL https://direnv.net/install.sh | bash
EOF

sed -i 's/^plugins=(\(.*\))/plugins=(\1 direnv)/' /home/$_CONTAINER_USER/.zshrc