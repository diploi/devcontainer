#!/usr/bin/env bash

set -eax

# Fix permissions on the share folder
mkdir -p /home/$_CONTAINER_USER/.local/share
chown $_CONTAINER_USER:$_CONTAINER_USER /home/$_CONTAINER_USER/.local/share

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

# Move to /app on login
cat <<EOF >> /home/$_CONTAINER_USER/.zshrc
cd /app
EOF

# Create the runonce.sh script
cat > /usr/local/bin/diploi-runonce.sh <<EOT
#!/bin/sh

#
# Script to initialize a new development environment
#

if [ -d "/home/diploi-tmp" ] && [ -z "\$( ls -A '/home/diploi-tmp' )" ]; then
  # Copy home directory files from the Docker build if the actual home folder is empty
  echo "First boot detected. Will copy the home folder contents."
  mv -n /home/$_CONTAINER_USER/.[!.]* /home/diploi-tmp/

else
  echo "Not the first boot. Skipping home folder init."
fi
EOT

echo "Creating Continue configuration file..."
mkdir -p /home/$_CONTAINER_USER/.continue

chown -R $_CONTAINER_USER:$_CONTAINER_USER /home/$_CONTAINER_USER/.continue


# Create the diploi system rule files
cat > /home/$_CONTAINER_USER/DiploiAISystemRules.md <<EOT
---
name: Diploi Continue Extension Rules
alwaysApply: true
description: Additional information for coding projects in Diploi, applied to all AI models used in Continue extension
---

# Diploi System Prompt
You are an AI assistant that understands how applications are built, deployed, and hosted on **Diploi**.
All answers relevant to Diploi must reflect real Diploi behavior, features, and system architecture.
When users report errors, logs, or unexpected behavior, diagnose them using Diploi's build pipeline, environment model, and runtime behavior.
More detailed instructions formatted for LLM's can be found at https://docs.diploi.com/llms-full.txt

## Core Behavior
- Diagnose issues using Diploi's build, deployment, and hosting model.
- Use "diploi logs <component identifier> --follow" to stream real-time logs in the terminal.
- Go through the "diploi.yaml" file to understand the tech components, stack, and configuration used in the codespace.
- All code can be found inside of the /app directory; request clarification for anything outside it unless the user explicitly provides those files.
- Only call tools that are explicitly listed in the "tools" array. Do not invent or reference any other tool. If unsure, respond normally instead of calling a tool.
- When doing code changes, all components have hot-realoding enabled. No need to ask the user to run a command, just ask them to reload the page, or open the component page from Diploi Console.
- If the code requires environment variables, instruct the user to open the Deployment Options in Diploi Console, and add the required variables in the Environment section of the related component.
If a Diploi feature or behavior is uncertain, state that clearly and refer the user to: https://docs.diploi.com/

## Monorepo Structure & diploi.yaml Specification:
The file diploi.yaml provides:
- A list of all technologies, frameworks, components, and addons used in this project.
- A mapping from each component or addon to the folder(s) associated with it.
  - If a "folder" field is present, that is used, if not, a folder with the same name as the "identifier" field is used
- Links to repositories that contain example implementations and documentation for the relevant components or addons.

For detailed definitions and usage guidelines, refer to "diploi.yaml Explained" at https://docs.diploi.com/llms-full.txt

## Rules
- Provide clear, actionable, Diploi-specific debugging steps.
- Do not speculate about undocumented features.
EOT



# Create the diploi-continue-setup.sh script
cat > /usr/local/bin/diploi-continue-setup.sh <<EOT
#!/bin/sh

#
# Script to setup Continue in the development environment
#
if ! mkdir -p /home/diploi-tmp/.continue ; then
  echo "Could not create /home/diploi-tmp/.continue folder"
  exit 1
fi

if [ ! -f /home/diploi-tmp/.continue/config.yaml ]; then  
  echo "Creating Continue config file..."
  cp /continue-readonly/config.yaml /home/diploi-tmp/.continue/config.yaml
  
  echo "Setting permissions for Continue config folder..."
  chown -R 1000:1000 /home/diploi-tmp/.continue && chmod -R u+w /home/diploi-tmp/.continue
fi

# Ensure the rules directory exists before copying
if [ ! -d /home/diploi-tmp/.continue/rules ]; then
  echo "Creating Continue rules directory..."
  mkdir -p /home/diploi-tmp/.continue/rules
fi

if [ ! -f /home/diploi-tmp/.continue/rules/DiploiAISystemRules.md ] && [ -f /home/$_CONTAINER_USER/DiploiAISystemRules.md ]; then
  echo "Creating Diploi Continue system rule file..."
  cp /home/$_CONTAINER_USER/DiploiAISystemRules.md /home/diploi-tmp/.continue/rules/DiploiAISystemRules.md
  echo "Setting permissions for Continue rules folder..."
  chown -R 1000:1000 /home/diploi-tmp/.continue/rules
  chmod -R u-w /home/diploi-tmp/.continue/rules/DiploiAISystemRules.md
fi

EOT

chmod +x /usr/local/bin/diploi-runonce.sh
chmod +x /usr/local/bin/diploi-continue-setup.sh