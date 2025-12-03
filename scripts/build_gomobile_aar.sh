#!/bin/bash
set -e

# Script to only build the gomobile AAR library

echo "Building Go Mobile AAR for Android..."

# Check if gomobile is installed
if ! command -v gomobile &> /dev/null; then
    echo "gomobile not found. Installing..."
    go install golang.org/x/mobile/cmd/gomobile@latest
    gomobile init
fi

# Create libs directory if it doesn't exist
mkdir -p android/app/libs

# Build the AAR file for Android
gomobile bind -target=android -androidapi=21 -o android/app/libs/mobile.aar ./mobile

echo "AAR build complete: android/app/libs/mobile.aar"
