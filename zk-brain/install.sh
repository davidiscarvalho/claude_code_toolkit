#!/bin/bash
# Install zk-brain to ~/.claude/zk_brain/

set -e

INSTALL_DIR="$HOME/.claude/zk_brain"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing zk-brain to $INSTALL_DIR..."

# Create directory
mkdir -p "$INSTALL_DIR"

# Copy script
cp "$SCRIPT_DIR/scripts/zk" "$INSTALL_DIR/zk"
chmod +x "$INSTALL_DIR/zk"

# Initialize database
"$INSTALL_DIR/zk" init

# Add to PATH instructions
echo ""
echo "✓ Installed successfully!"
echo ""
echo "Add to your shell config (~/.bashrc or ~/.zshrc):"
echo ""
echo '  export PATH="$HOME/.claude/zk_brain:$PATH"'
echo ""
echo "Or create a symlink:"
echo ""
echo "  sudo ln -sf $INSTALL_DIR/zk /usr/local/bin/zk"
echo ""
echo "Then run: zk help"
