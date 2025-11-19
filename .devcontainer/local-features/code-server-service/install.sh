#!/usr/bin/env bash

set -eax

cat <<EOT >> /etc/supervisord.conf
; Added by code-server-service feature
[program:code-server]
directory=/app
user=$USERNAME
environment=HOME="/home/$USERNAME"
command=/usr/local/bin/code-server-entrypoint
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
priority=10
stout_logfile=/var/log/supervisor/code-server.log
stderr_logfile=/var/log/supervisor/code-server.err.log

[program:install-extensions]
command=/bin/sh -c 'date; echo "Sleeping 5 seconds..."; sleep 5; date; echo "Running install"; sudo -u ${$USERNAME} bash -c "code-server --install-extension Continue.continue --force" && echo "✅ Extension installed successfully."'
autostart=true
autorestart=true
priority=20
stdout_logfile=/var/log/supervisor/install-extensions.log
stderr_logfile=/var/log/supervisor/install-extensions.err.log

EOT