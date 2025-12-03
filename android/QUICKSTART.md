# Quick Start Guide - SilverBullet Android

## Prerequisites Check

Before building, ensure you have:

```bash
# Check Go version (need 1.25.1+)
go version

# Check Deno
deno --version

# Check Java (need JDK 17+)
java -version

# Check Android SDK
echo $ANDROID_HOME
# Should output something like: /home/user/Android/Sdk
```

## Setup (First Time Only)

### 1. Install gomobile

```bash
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init
```

### 2. Set Environment Variables

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$GOPATH/bin
```

Reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

## Build & Install

### Option 1: One Command (Easiest)

From the SilverBullet project root:

```bash
make android
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

### Option 2: Step by Step

```bash
# 1. Build Deno client
deno task build-production

# 2. Build Go Mobile AAR
make android-aar

# 3. Build Android APK
cd android
./gradlew assembleDebug

# 4. Install on device
adb install app/build/outputs/apk/debug/app-debug.apk
```

## First Time Build Issues?

### Missing Icons

The app needs launcher icons to build. Quick fix:

```bash
cd android
./create_placeholder_icons.sh
```

Or see `app/src/main/res/ICON_README.md` for manual steps.

### Missing Gradle Wrapper JAR

If you get "gradle-wrapper.jar not found":

```bash
cd android
gradle wrapper
```

### gomobile not found

```bash
go install golang.org/x/mobile/cmd/gomobile@latest
export PATH=$PATH:$GOPATH/bin
gomobile init
```

### ANDROID_HOME not set

Find your Android SDK location (usually):
- Linux: `~/Android/Sdk`
- Mac: `~/Library/Android/sdk`

Then:
```bash
export ANDROID_HOME=<your-sdk-path>
```

## Running the App

### Install and Launch

```bash
# Install
adb install android/app/build/outputs/apk/debug/app-debug.apk

# Launch
adb shell am start -n md.silverbullet/.MainActivity
```

### View Logs

```bash
# All logs
adb logcat | grep SilverBullet

# Just errors
adb logcat | grep -E "SilverBullet|AndroidRuntime"
```

## Making Changes

### Changed Go Code?

```bash
make android-aar
cd android && ./gradlew assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

### Changed Android Code?

```bash
cd android
./gradlew assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

### Changed Client Code?

```bash
deno task build-production
make android-aar
cd android && ./gradlew assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

## Clean Build

If things go wrong:

```bash
# Clean everything
make android-clean

# Then rebuild
make android
```

## Testing

### Check if device is connected

```bash
adb devices
```

Should show:
```
List of devices attached
XXXXXXXXXX      device
```

### Test the server directly

After installing the app and launching it:

```bash
# Forward port from device
adb forward tcp:3000 tcp:3000

# Access in your browser
open http://localhost:3000
```

## Common Build Times

On a typical development machine:

- First build: 5-10 minutes
- Subsequent builds: 1-2 minutes
- AAR only rebuild: 30-60 seconds
- Android only rebuild: 20-30 seconds

## File Sizes

Expected artifact sizes:

- `mobile.aar`: ~40-60 MB
- `app-debug.apk`: ~50-70 MB

## Next Steps

1. ✅ Built successfully? Great! See `README.md` for full documentation
2. ❌ Build failed? Check the troubleshooting section in `README.md`
3. Want to customize? See `README.md` for configuration options

## Quick Reference

```bash
# Full build
make android

# Just Go Mobile library
make android-aar

# Clean build artifacts
make android-clean

# Install on device
adb install android/app/build/outputs/apk/debug/app-debug.apk

# View logs
adb logcat | grep SilverBullet

# Uninstall
adb uninstall md.silverbullet
```

## Getting Help

- **Detailed docs**: See `README.md` in this directory
- **Main project docs**: See `../ANDROID.md`
- **Icon help**: See `app/src/main/res/ICON_README.md`
- **Go Mobile docs**: https://go.dev/wiki/Mobile

## Success Checklist

- [ ] Go 1.25.1+ installed
- [ ] Deno installed
- [ ] JDK 17+ installed
- [ ] Android SDK installed
- [ ] ANDROID_HOME set
- [ ] gomobile installed and initialized
- [ ] Device connected via USB or emulator running
- [ ] Built successfully with `make android`
- [ ] Installed successfully with `adb install`
- [ ] App launches and shows SilverBullet interface

If all checked, you're ready to go! 🎉
