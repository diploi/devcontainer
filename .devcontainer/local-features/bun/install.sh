#!/usr/bin/env bash

set -eax

sudo -iu $_REMOTE_USER <<EOF
    curl -fsSL https://bun.sh/install | bash
EOF

# Copy (not symlink) the binary so it works even when the runtime home volume lacks ~/.bun
install -m 755 $_REMOTE_USER_HOME/.bun/bin/bun /usr/local/bin/bun