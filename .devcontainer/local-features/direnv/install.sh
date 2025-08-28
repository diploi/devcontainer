#!/usr/bin/env bash

set -eax

sudo -iu $_REMOTE_USER <<EOF
    curl -sfL https://direnv.net/install.sh | bash
EOF

cat <<EOF >> /home/$_CONTAINER_USER/.bashrc
eval "$(direnv hook bash)"
EOF

cat <<EOF >> /home/$_CONTAINER_USER/.zshrc
eval "$(direnv hook zsh)"
EOF