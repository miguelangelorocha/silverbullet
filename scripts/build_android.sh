#!/bin/bash
set -e

# Build script for SilverBullet Android App using gomobile

echo "Building SilverBullet Android App..."

# Check if gomobile is installed
if ! command -v gomobile &> /dev/null; then
    echo "gomobile not found. Installing..."
    go install golang.org/x/mobile/cmd/gomobile@latest
    gomobile init
fi

# Create libs directory if it doesn't exist
mkdir -p android/app/libs

echo "Building Go Mobile AAR..."
# Build the AAR file for Android
gomobile bind -target=android -androidapi=21 -o android/app/libs/mobile.aar ./mobile

echo "Building Deno client..."
# Build the client bundle (required for embedded files)
deno task build-production

echo "Building APK with Gradle..."
cd android
./gradlew assembleDebug

echo ""
echo "Build complete!"
echo "APK location: android/app/build/outputs/apk/debug/app-debug.apk"
echo ""
echo "To install on device: adb install android/app/build/outputs/apk/debug/app-debug.apk"
