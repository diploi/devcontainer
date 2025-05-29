#!/usr/bin/env bash

set -eax

# Create the diploi-credential-helper
cat > /usr/local/bin/diploi-credential-helper <<'EOT'
#!/bin/sh

#
# Script for continuous updates of github write token for repository
#

mkdir -p ~/.diploi
LOG=~/.diploi/git-credential-helper.log

echo `date -u +"%Y-%m-%dT%H:%M:%SZ"` Starting $1 >> $LOG

# Check that the helper is called with the "get" argument
test "$1" = get || exit 2;

# Read core token from file
ct=`cat /etc/diploi-git/credential-token` || exit 3;

echo `date -u +"%Y-%m-%dT%H:%M:%SZ"` CredentialToken $ct >> $LOG

# Call the core API endpoint with the token
gt=`curl -s -X GET http://core.diploi/git-token/$ct` || exit 4;

echo `date -u +"%Y-%m-%dT%H:%M:%SZ"` AccessToken $gt >> $LOG

# Pick the relevant information from the output
username=`echo "$gt" | sed -n '1p'`;
password=`echo "$gt" | sed -n '2p'`;

echo `date -u +"%Y-%m-%dT%H:%M:%SZ"` username=$username >> $LOG
echo `date -u +"%Y-%m-%dT%H:%M:%SZ"` password=$password >> $LOG

# Write credentials to helper output
echo "username=$username";
echo "password=$password";
EOT
chmod +x /usr/local/bin/diploi-credential-helper

# Symlink the Diploi provided gitconfig to be used by the user
ln -s /etc/diploi-git/gitconfig /etc/gitconfig

# Configure VS Code
mkdir -p /home/$_CONTAINER_USER/.local/share/code-server/User
cat > /home/$_CONTAINER_USER/.local/share/code-server/User/settings.json <<EOT
{
  "workbench.colorTheme": "Default Dark Modern",
  "workbench.startupEditor": "none",
  "go.toolsManagement.checkForUpdates": "local",
  "go.useLanguageServer": true,
  "go.gopath": "/go",
  "python.defaultInterpreterPath": "/home/$_CONTAINER_USER/.python/current/bin/python3",
  "jupyter.kernels.filter": [
    {
      "path": "/opt/conda/bin/python",
      "type": "pythonEnvironment"
    },
    {
      "path": "/usr/local/python/current/bin/python3",
      "type": "pythonEnvironment"
    },
    {
      "path": "/usr/local/python/current/bin/python",
      "type": "pythonEnvironment"
    },
    {
      "path": "/usr/bin/python3",
      "type": "pythonEnvironment"
    },
    {
      "path": "/bin/python3",
      "type": "pythonEnvironment"
    }
  ],
  "lldb.executable": "/usr/bin/lldb"
}
EOT
chown -R $_CONTAINER_USER:$_CONTAINER_USER /home/$_CONTAINER_USER/.local/share/code-server

# Create a nice welcome message
# Logo generated with "figlet -f small Diploi | /usr/games/lolcat -p 1.9 -S 20 --force > motd.txt"
cat > /etc/motd <<'EOT'
 [38;5;199m [39m[38;5;199m_[39m[38;5;199m_[39m[38;5;199m_[39m[38;5;199m [39m[38;5;199m [39m[38;5;163m_[39m[38;5;164m [39m[38;5;164m [39m[38;5;164m [39m[38;5;164m [39m[38;5;164m [39m[38;5;164m [39m[38;5;164m_[39m[38;5;128m [39m[38;5;129m [39m[38;5;129m [39m[38;5;129m [39m[38;5;129m [39m[38;5;129m_[39m[38;5;93m [39m[38;5;93m[39m
 [38;5;199m|[39m[38;5;199m [39m[38;5;199m [39m[38;5;199m [39m[38;5;163m\[39m[38;5;164m([39m[38;5;164m_[39m[38;5;164m)[39m[38;5;164m_[39m[38;5;164m [39m[38;5;164m_[39m[38;5;164m_[39m[38;5;128m|[39m[38;5;129m [39m[38;5;129m|[39m[38;5;129m_[39m[38;5;129m_[39m[38;5;129m_[39m[38;5;93m([39m[38;5;93m_[39m[38;5;93m)[39m[38;5;93m[39m
 [38;5;199m|[39m[38;5;199m [39m[38;5;163m|[39m[38;5;164m)[39m[38;5;164m [39m[38;5;164m|[39m[38;5;164m [39m[38;5;164m|[39m[38;5;164m [39m[38;5;164m'[39m[38;5;128m_[39m[38;5;129m [39m[38;5;129m\[39m[38;5;129m [39m[38;5;129m/[39m[38;5;129m [39m[38;5;93m_[39m[38;5;93m [39m[38;5;93m\[39m[38;5;93m [39m[38;5;93m|[39m[38;5;93m[39m
 [38;5;163m|[39m[38;5;164m_[39m[38;5;164m_[39m[38;5;164m_[39m[38;5;164m/[39m[38;5;164m|[39m[38;5;164m_[39m[38;5;164m|[39m[38;5;128m [39m[38;5;129m.[39m[38;5;129m_[39m[38;5;129m_[39m[38;5;129m/[39m[38;5;129m_[39m[38;5;129m\[39m[38;5;93m_[39m[38;5;93m_[39m[38;5;93m_[39m[38;5;93m/[39m[38;5;93m_[39m[38;5;93m|[39m[38;5;63m[39m
 [38;5;164m [39m[38;5;164m [39m[38;5;164m [39m[38;5;164m [39m[38;5;164m [39m[38;5;164m [39m[38;5;128m [39m[38;5;129m|[39m[38;5;129m_[39m[38;5;129m|[39m[38;5;129m [39m[38;5;129m [39m[38;5;129m [39m[38;5;93m [39m[38;5;93m [39m[38;5;93m [39m[38;5;93m [39m[38;5;93m [39m[38;5;93m [39m[38;5;63m [39m[38;5;63m [39m[38;5;63m[39m

 [0;37m👋 Welcome to your Diploi development environment!
    - Your app processes are [1;37mnot[0;37m running here (like node or bun).
      To manage them, use the Diploi dashboard.
    - You can run commands like "npm install" here.
    - You can edit your code here. Changes are instantly reflected to all components.

 👇 Learn more about remote development with Diploi:
    [38;5;128mhttps://diploi.com/dev[0;37m

 [1;37mHappy coding! ✨

EOT

# Print the welcome message on login
cat <<EOF >> /home/$_CONTAINER_USER/.zshrc
cat /etc/motd
EOF

# Create the runonce.sh script
cat > /usr/local/bin/diploi-runonce.sh <<EOT
#!/bin/sh

#
# Script to initialize a new development environment
#

if [ -d "/home/diploi-tmp" ] && [ -z "\$( ls -A '/home/$_CONTAINER_USER' )" ]; then
  # Copy home directory files from the Docker build if they exist and the actual home folder is empty
  echo "First boot detected. Will copy the home folder contents."
  shopt -s dotglob
  mv -vn /home/diploi-tmp/* /home/$_CONTAINER_USER/
fi

rm -rf /home/diploi-tmp

# Start the code-server
supervisorctl start code-server

EOT
chmod +x /usr/local/bin/diploi-runonce.sh

# Create a supervisor task for the runonce.sh
cat <<EOT >> /etc/supervisord.conf
; Added by diploi feature
[program:runonce]
directory=/home/$_CONTAINER_USER
command=sh /usr/local/bin/diploi-runonce.sh
autostart=true
autorestart=false
startretries=0
stdout_logfile=/var/log/runonce.log
stderr_logfile=/var/log/runonce.log

EOT

# Move home folder contents to a temporary folder from which they will be copied to the mount
mv /home/$_CONTAINER_USER /home/diploi-tmp
mkdir /home/$_CONTAINER_USER
chown $_CONTAINER_USER:$_CONTAINER_USER /home/$_CONTAINER_USER