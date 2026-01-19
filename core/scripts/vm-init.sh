#!/bin/bash
# vm-init.sh - Run automatically when VM starts
# Installs everything needed for Ralph

set -e

echo "=== Ralph VM Setup ==="

# Update system
sudo apt-get update

# Install basic tools
sudo apt-get install -y curl git ripgrep jq tmux

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Fix nvm path issues - add to profile if using nvm
if [ -d "$HOME/.nvm" ]; then
    echo "=== Configuring nvm path ==="
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Add to bashrc if not already there
    if ! grep -q "NVM_DIR" ~/.bashrc 2>/dev/null; then
        echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
    fi
fi

# Install Claude Code CLI
sudo npm install -g @anthropic-ai/claude-code

# Install GitHub CLI
echo "=== Installing GitHub CLI ==="
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt-get update
sudo apt-get install -y gh

# Install GitLab CLI
echo "=== Installing GitLab CLI ==="
curl -fsSL "https://gitlab.com/gitlab-org/cli/-/releases/permalink/latest/downloads/glab_$(uname -s)_$(uname -m).deb" -o /tmp/glab.deb
sudo dpkg -i /tmp/glab.deb || sudo apt-get install -f -y
rm -f /tmp/glab.deb

# Install Playwright dependencies (for E2E tests)
echo "=== Installing Playwright dependencies ==="
sudo npx playwright install-deps || true
npx playwright install || true

# Create workspace
mkdir -p ~/workspace
mkdir -p ~/scripts
mkdir -p ~/specs

echo ""
echo "=== Installation complete! ==="
echo ""
echo "Next steps (one-time configuration):"
echo "1. Log in to Claude:  claude login"
echo "2. Log in to your git host:"
echo "   - GitHub: gh auth login"
echo "   - GitLab: glab auth login"
echo ""
echo "Then the VM is ready for Ralph!"
