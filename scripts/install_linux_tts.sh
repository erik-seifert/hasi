#!/bin/bash

# Script to install and test Linux TTS engines for the HASI Flutter app

echo "==================================="
echo "Linux TTS Setup for HASI"
echo "==================================="
echo ""

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "❌ This script is only for Linux systems"
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for existing TTS engines
echo "Checking for existing TTS engines..."
echo ""

if command_exists espeak-ng; then
    echo "✅ espeak-ng is already installed"
    ESPEAK_VERSION=$(espeak-ng --version | head -n1)
    echo "   Version: $ESPEAK_VERSION"
elif command_exists espeak; then
    echo "✅ espeak is already installed"
    ESPEAK_VERSION=$(espeak --version | head -n1)
    echo "   Version: $ESPEAK_VERSION"
else
    echo "❌ espeak-ng/espeak not found"
    echo ""
    echo "Installing espeak-ng..."
    
    # Detect package manager and install
    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y espeak-ng
    elif command_exists dnf; then
        sudo dnf install -y espeak-ng
    elif command_exists pacman; then
        sudo pacman -S --noconfirm espeak-ng
    elif command_exists zypper; then
        sudo zypper install -y espeak-ng
    else
        echo "❌ Could not detect package manager. Please install espeak-ng manually:"
        echo "   Ubuntu/Debian: sudo apt install espeak-ng"
        echo "   Fedora: sudo dnf install espeak-ng"
        echo "   Arch: sudo pacman -S espeak-ng"
        exit 1
    fi
    
    if command_exists espeak-ng; then
        echo "✅ espeak-ng installed successfully"
    else
        echo "❌ Installation failed"
        exit 1
    fi
fi

echo ""
echo "==================================="
echo "Testing TTS..."
echo "==================================="
echo ""

# Test espeak-ng
if command_exists espeak-ng; then
    echo "Testing espeak-ng..."
    espeak-ng -v en-us -s 150 "Hello from HASI. Text to speech is working on Linux."
    echo "✅ espeak-ng test complete"
elif command_exists espeak; then
    echo "Testing espeak..."
    espeak -v en-us -s 150 "Hello from HASI. Text to speech is working on Linux."
    echo "✅ espeak test complete"
fi

echo ""
echo "==================================="
echo "Setup Complete!"
echo "==================================="
echo ""
echo "Your Flutter app will now use native Linux TTS."
echo "Run your app with: flutter run -d linux"
echo ""
