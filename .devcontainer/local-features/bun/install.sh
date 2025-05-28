#!/usr/bin/env bash

set -eax

sudo -iu $_REMOTE_USER <<EOF
    curl -fsSL https://bun.sh/install | bash
EOF

ln -s $_REMOTE_USER_HOME/.bun/bin/bun /usr/local/bin/bun