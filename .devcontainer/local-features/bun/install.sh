#!/usr/bin/env bash

set -eax

sudo -iu $_REMOTE_USER <<EOF
    curl -fsSL https://bun.sh/install | bash
EOF

# Resolve the user's home directory (do not rely on _REMOTE_USER_HOME, which may be unset here)
REMOTE_USER_HOME=$(getent passwd "$_REMOTE_USER" | cut -d: -f6)

# Copy (not symlink) the binary so it works even when the runtime home volume lacks ~/.bun
install -m 755 "$REMOTE_USER_HOME/.bun/bin/bun" /usr/local/bin/bun