#!/usr/bin/env bash

set -eax

cat <<EOT >> /etc/supervisord.conf
; Added by code-server-service feature
[program:code-server]
directory=/app
user=$_CONTAINER_USER
environment=HOME="/home/$_CONTAINER_USER"
command=/usr/local/bin/code-server-entrypoint
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true

EOT