#!/bin/bash
#
# Install Android SDK for SilverBullet Android development
# This script installs the Android command-line tools and required SDK components
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ANDROID_SDK_VERSION="11076708"
ANDROID_PLATFORM="21"
BUILD_TOOLS_VERSION="28.0.3"
NDK_VERSION="27.2.12479018"

echo -e "${GREEN}Installing Android SDK for SilverBullet Android development${NC}"
echo ""

# Detect OS
OS_TYPE=$(uname -s)
case "$OS_TYPE" in
    Linux*)
        CMDTOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip"
        ;;
    Darwin*)
        CMDTOOLS_URL="https://dl.google.com/android/repository/commandlinetools-mac-${ANDROID_SDK_VERSION}_latest.zip"
        ;;
    *)
        echo -e "${RED}Unsupported operating system: $OS_TYPE${NC}"
        exit 1
        ;;
esac

# Set ANDROID_HOME
if [ -z "$ANDROID_HOME" ]; then
    ANDROID_HOME="$HOME/Android/Sdk"
    echo -e "${YELLOW}ANDROID_HOME not set. Using default: $ANDROID_HOME${NC}"
fi

# Check if SDK already exists
if [ -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
    echo -e "${YELLOW}Android SDK command-line tools already installed at $ANDROID_HOME${NC}"
    read -p "Do you want to reinstall? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping SDK installation. Will check for required components..."
    else
        echo "Removing existing installation..."
        rm -rf "$ANDROID_HOME/cmdline-tools"
    fi
fi

# Create Android SDK directory
echo "Creating Android SDK directory: $ANDROID_HOME"
mkdir -p "$ANDROID_HOME"

# Download command-line tools if not already installed
if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
    echo "Downloading Android command-line tools..."
    TEMP_ZIP="$ANDROID_HOME/cmdtools.zip"
    
    if command -v wget &> /dev/null; then
        wget -q --show-progress "$CMDTOOLS_URL" -O "$TEMP_ZIP"
    elif command -v curl &> /dev/null; then
        curl -L --progress-bar "$CMDTOOLS_URL" -o "$TEMP_ZIP"
    else
        echo -e "${RED}Error: Neither wget nor curl is available. Please install one of them.${NC}"
        exit 1
    fi

    # Extract command-line tools
    echo "Extracting command-line tools..."
    cd "$ANDROID_HOME"
    unzip -q "$TEMP_ZIP"
    
    # Move to correct location
    mkdir -p cmdline-tools/latest
    mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
    
    # Clean up
    rm "$TEMP_ZIP"
    echo -e "${GREEN}✓ Command-line tools installed${NC}"
fi

# Set up environment for current session
export ANDROID_HOME
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin"

# Accept licenses
echo ""
echo "Accepting Android SDK licenses..."
yes | sdkmanager --licenses > /dev/null 2>&1 || true

# Install required SDK components
echo ""
echo "Installing required SDK components..."
echo "  - Android SDK Platform $ANDROID_PLATFORM"
echo "  - Build Tools $BUILD_TOOLS_VERSION"
echo "  - NDK $NDK_VERSION"
echo "  - Platform Tools"
echo ""

sdkmanager \
    "platforms;android-${ANDROID_PLATFORM}" \
    "build-tools;${BUILD_TOOLS_VERSION}" \
    "ndk;${NDK_VERSION}" \
    "platform-tools"

# Verify installation
echo ""
echo -e "${GREEN}Verifying installation...${NC}"
sdkmanager --list_installed | grep -E "platforms|build-tools|ndk|platform-tools"

# Update shell configuration
echo ""
echo "Setting up environment variables..."

SHELL_CONFIG=""
if [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
else
    SHELL_CONFIG="$HOME/.profile"
fi

# Check if already configured
if grep -q "ANDROID_HOME" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}Android SDK environment variables already configured in $SHELL_CONFIG${NC}"
else
    echo "" >> "$SHELL_CONFIG"
    echo "# Android SDK" >> "$SHELL_CONFIG"
    echo "export ANDROID_HOME=\$HOME/Android/Sdk" >> "$SHELL_CONFIG"
    echo "export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin" >> "$SHELL_CONFIG"
    echo "export PATH=\$PATH:\$ANDROID_HOME/platform-tools" >> "$SHELL_CONFIG"
    echo "export PATH=\$PATH:\$ANDROID_HOME/tools" >> "$SHELL_CONFIG"
    echo "export PATH=\$PATH:\$ANDROID_HOME/tools/bin" >> "$SHELL_CONFIG"
    echo -e "${GREEN}✓ Environment variables added to $SHELL_CONFIG${NC}"
fi

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Android SDK Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Installation directory: $ANDROID_HOME"
echo ""
echo "Installed components:"
echo "  ✓ Android SDK Platform $ANDROID_PLATFORM"
echo "  ✓ Build Tools $BUILD_TOOLS_VERSION"
echo "  ✓ NDK $NDK_VERSION"
echo "  ✓ Platform Tools (adb, etc.)"
echo ""
echo "Environment variables configured in: $SHELL_CONFIG"
echo ""
echo -e "${YELLOW}Important:${NC} Reload your shell configuration or restart your terminal:"
echo "  source $SHELL_CONFIG"
echo ""
echo "Verify installation:"
echo "  echo \$ANDROID_HOME"
echo "  which adb"
echo "  which sdkmanager"
echo ""
echo "You can now proceed with building the Android app:"
echo "  make android"
echo ""
