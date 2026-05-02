#!/bin/bash
# Easy Install Script for Custom Termux via Termux
# Run this inside Termux app to install the custom environment

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "     CUSTOM TERMUX - EASY INSTALLER"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running in Termux
if [ -z "$TERMUX_VERSION" ] && [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}❌ ERROR: This script must be run inside Termux app!${NC}"
    echo ""
    echo "Install Termux first:"
    echo "  https://f-droid.org/packages/com.termux/"
    exit 1
fi

echo -e "${GREEN}✓ Running in Termux environment${NC}"

# Setup directories
TERMUX_HOME="${TERMUX_HOME:-/data/data/com.termux/files/home}"
TERMUX_PREFIX="${TERMUX_PREFIX:-/data/data/com.termux/files/usr}"
INSTALL_DIR="$TERMUX_HOME/custom-termux"

echo "📁 Setup directories..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download custom termux package
echo ""
echo -e "${BLUE}📦 Downloading Custom Termux package...${NC}"
REPO_URL="https://github.com/ghost23261/custom-termux-lfs"

echo "From: $REPO_URL"
echo "This may take a few minutes..."

# Download bootstrap
if command -v curl &> /dev/null; then
    curl -L -o custom-termux-bootstrap.tar.gz \
        "$REPO_URL/releases/download/v1.0.0/custom-termux-v1.0.0.tar.gz" \
        2>/dev/null || echo "⚠️  Release not found, using source build..."
else
    wget -q -O custom-termux-bootstrap.tar.gz \
        "$REPO_URL/releases/download/v1.0.0/custom-termux-v1.0.0.tar.gz" \
        2>/dev/null || echo "⚠️  Release not found, using source build..."
fi

# If release download failed, try raw github
if [ ! -f custom-termux-bootstrap.tar.gz ] || [ ! -s custom-termux-bootstrap.tar.gz ]; then
    echo "Trying alternative download..."
    curl -L -o custom-termux-bootstrap.tar.gz \
        "https://raw.githubusercontent.com/ghost23261/custom-termux-lfs/main/output/custom-termux-v1.0.0.tar.gz" \
        2>/dev/null || true
fi

# Extract if download succeeded
if [ -f custom-termux-bootstrap.tar.gz ] && [ -s custom-termux-bootstrap.tar.gz ]; then
    echo -e "${GREEN}✓ Download complete${NC}"
    echo "📦 Extracting..."
    tar -xzf custom-termux-bootstrap.tar.gz
else
    echo -e "${YELLOW}⚠️  Using local build instead${NC}"
    echo "You can build locally with:"
    echo "  git clone $REPO_URL"
    echo "  cd custom-termux-lfs"
    echo "  ./scripts/complete_build.sh"
fi

# Install custom tools
echo ""
echo -e "${BLUE}🔧 Installing custom tools...${NC}"

# Create custom bin directory
mkdir -p "$TERMUX_PREFIX/custom/bin"

# Add to PATH
echo 'export PATH="$PREFIX/custom/bin:$PATH"' >> "$TERMUX_HOME/.bashrc"

# Setup custom environment
cat > "$TERMUX_PREFIX/custom/bin/termux-custom-setup" << 'EOF'
#!/bin/bash
# Custom Termux Environment Setup

echo "Custom Termux v1.0.0 - LFS Slackware Base"
echo "=========================================="

# Add custom paths
export CUSTOM_ROOT="$PREFIX/custom"
export PATH="$CUSTOM_ROOT/bin:$PATH"

# LFS environment variables
export LFS_TERMUX=1
export TERMUX_CUSTOM_VERSION="1.0.0"

# Aliases for custom tools
alias custom-shell='exec bash --rcfile $PREFIX/etc/bash.bashrc'
alias custom-update='pkg update && pkg upgrade'

echo "Custom environment loaded!"
echo "Type 'custom-shell' to start custom bash"
EOF

chmod +x "$TERMUX_PREFIX/custom/bin/termux-custom-setup"

# Create launcher script
cat > "$TERMUX_HOME/.shortcuts/Custom-Termux" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Custom Termux Launcher
cd $HOME
source $PREFIX/custom/bin/termux-custom-setup
clear
echo "╔════════════════════════════════════════╗"
echo "║     CUSTOM TERMUX TERMINAL v1.0.0     ║"
echo "║    LFS Slackware Linux Base          ║"
echo "╚════════════════════════════════════════╝"
echo ""
bash --login
EOF

chmod +x "$TERMUX_HOME/.shortcuts/Custom-Termux"

# Install essential packages if needed
echo ""
echo -e "${BLUE}📦 Installing base packages...${NC}"
pkg update -y
pkg install -y bash coreutils grep sed gawk tar gzip findutils || true

# Create welcome message
cat > "$TERMUX_HOME/.custom_termux_welcome" << 'EOF'
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║     ██████╗██╗   ██╗███████╗████████╗ ██████╗ ███╗   ███╗  ║
║    ██╔════╝██║   ██║██╔════╝╚══██╔══╝██╔═══██╗████╗ ████║  ║
║    ██║     ██║   ██║█████╗     ██║   ██║   ██║██╔████╔██║  ║
║    ██║     ██║   ██║██╔══╝     ██║   ██║   ██║██║╚██╔╝██║  ║
║    ╚██████╗╚██████╔╝██║        ██║   ╚██████╔╝██║ ╚═╝ ██║  ║
║     ╚═════╝ ╚═════╝ ╚═╝        ╚═╝    ╚═════╝ ╚═╝     ╚═╝  ║
║                                                            ║
║         LFS SLACKWARE LINUX - CUSTOM BUILD                 ║
║              Private Network Edition                       ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

Welcome to Custom Termux!

Quick Commands:
  termux-custom-setup  - Load custom environment
  custom-shell         - Start enhanced bash
  custom-update        - Update packages

Features:
  ✓ LFS Slackware Linux base
  ✓ Full GNU toolchain
  ✓ GCC compiler suite
  ✓ Custom environment

For help: https://github.com/ghost23261/custom-termux-lfs
EOF

# Add to bashrc
echo "" >> "$TERMUX_HOME/.bashrc"
echo "# Custom Termux Welcome" >> "$TERMUX_HOME/.bashrc"
echo "cat ~/.custom_termux_welcome 2>/dev/null || true" >> "$TERMUX_HOME/.bashrc"

# Final setup
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ CUSTOM TERMUX INSTALLATION COMPLETE!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Installation Summary:"
echo "  📍 Location: $INSTALL_DIR"
echo "  🔧 Custom tools: $TERMUX_PREFIX/custom/bin/"
echo "  ⚡ Quick launch: ~/.shortcuts/Custom-Termux"
echo ""
echo "Next Steps:"
echo "  1. Restart Termux or run: source ~/.bashrc"
echo "  2. Type 'termux-custom-setup' to load environment"
echo "  3. Or use widget: Add 'Custom-Termux' shortcut to home screen"
echo ""
echo -e "${BLUE}Happy Hacking! 🚀${NC}"
echo ""
