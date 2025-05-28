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
cat > /etc/motd <<'EOT'
  ___  _      _     _ 
 |   \(_)_ __| |___(_)
 | |) | | '_ \ / _ \ |
 |___/|_| .__/_\___/_|
        |_|           

 👋 Welcome to your Diploi development environment!
   - Your app processes are *not* running here (like node or bun).
     To manage them, use the Diploi dashboard.
   - You can run commands like npm install here.
   - You can edit your code here. Changes are instantly reflected to all components.

   👇 Learn more about remote development with Diploi:
   https://diploi.com/dev

   Happy coding! ✨

EOT

# Print the welcome message on login
cat <<EOF >> /home/$_CONTAINER_USER/.zshrc
cat /etc/motd
EOF