#!/usr/bin/env bash

set -eax

VERSION="${VERSION:-latest}"

# The official installer accepts an optional release tag (e.g. "bun-v1.4.2"); omit it for latest
if [ "$VERSION" = "latest" ]; then
    BUN_RELEASE=""
else
    BUN_RELEASE="bun-v${VERSION#v}"
fi

sudo -iu $_REMOTE_USER <<EOT
    curl -fsSL https://bun.sh/install | bash -s ${BUN_RELEASE}
EOT

# Resolve the user's home directory (do not rely on _REMOTE_USER_HOME, which may be unset here)
REMOTE_USER_HOME=$(getent passwd "$_REMOTE_USER" | cut -d: -f6)

# Copy (not symlink) the binary so it works even when the runtime home volume lacks ~/.bun
install -m 755 "$REMOTE_USER_HOME/.bun/bin/bun" /usr/local/bin/bun
