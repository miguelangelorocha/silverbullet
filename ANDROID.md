# SilverBullet Android App Guide

This guide provides an overview of building and using the SilverBullet Android application.

## Overview

The SilverBullet Android app brings the full power of SilverBullet to your Android device. It runs the complete SilverBullet server natively on your phone or tablet, using Go Mobile technology.

## Quick Start

### Prerequisites

- Go 1.25.1+
- Deno (latest version)
- Android SDK with API level 24+ support
- gomobile tool

### Install gomobile

```bash
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init
```

### Build the App

From the project root:

```bash
# Build everything and create the APK
make android

# The APK will be at:
# android/app/build/outputs/apk/debug/app-debug.apk
```

### Install on Device

```bash
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

## Features

- **Native Performance**: Full Go server running natively on Android
- **Offline First**: No internet connection required
- **Complete Feature Set**: All SilverBullet features available
- **Private Storage**: Data stored securely in app private directory
- **No Server Setup**: Everything runs on your device

## Architecture

The Android app consists of:

1. **Go Mobile Library** (`mobile/mobile.go`): Exports server functions to Android
2. **Android App**: Minimal wrapper that starts the server and displays a WebView
3. **SilverBullet Server**: The full server running on `localhost:3000`

## Build Components

### 1. Go Mobile Package

Location: `mobile/mobile.go`

This package wraps the SilverBullet server in a way that can be called from Android:

```go
func StartServer(spaceFolderPath string, port int) error
func StopServer() error
func IsServerRunning() bool
func GetServerURL() string
```

### 2. Android Application

Location: `android/`

A standard Android app that:
- Starts the Go server on app launch
- Displays the web UI in a WebView
- Manages the server lifecycle
- Handles Android permissions

## Building Steps Explained

### Step 1: Build Client Bundle

```bash
deno task build-production
```

This creates the web client bundle that gets embedded in the Go binary.

### Step 2: Build Go Mobile AAR

```bash
make android-aar
# or
gomobile bind -target=android -o android/app/libs/mobile.aar ./mobile
```

This compiles the Go code into an Android Archive (AAR) library that can be imported by the Android app.

### Step 3: Build Android APK

```bash
cd android
./gradlew assembleDebug
```

This builds the Android application and links it with the Go Mobile library.

## Development Workflow

### Modify Go Code

```bash
# 1. Make changes to mobile/mobile.go or server code
# 2. Rebuild the AAR
make android-aar
# 3. Rebuild the APK
cd android && ./gradlew assembleDebug
```

### Modify Android Code

```bash
# Changes to MainActivity.java or resources
cd android && ./gradlew assembleDebug
```

### Debug on Device

```bash
# View logs
adb logcat | grep SilverBullet

# Install and run
adb install -r android/app/build/outputs/apk/debug/app-debug.apk
adb shell am start -n md.silverbullet/.MainActivity
```

## Makefile Targets

- `make android`: Full build (client + AAR + APK)
- `make android-aar`: Build only the Go Mobile AAR
- `make android-clean`: Clean Android build artifacts

## Project Structure

```
mobile/
  └── mobile.go                 # Go Mobile package

android/
  ├── README.md                 # Detailed Android documentation
  ├── build.gradle              # Project configuration
  ├── settings.gradle
  ├── gradle.properties
  └── app/
      ├── build.gradle          # App configuration
      ├── libs/                 # Contains mobile.aar (generated)
      └── src/main/
          ├── AndroidManifest.xml
          ├── java/md/silverbullet/
          │   └── MainActivity.java
          └── res/              # Android resources
              ├── layout/
              ├── values/
              └── mipmap-*/     # App icons

scripts/
  ├── build_android.sh          # Full Android build script
  └── build_gomobile_aar.sh     # AAR-only build script
```

## Configuration

### Server Port

Default: 3000 (localhost only)

Change in `android/app/src/main/java/md/silverbullet/MainActivity.java`:
```java
private static final int SERVER_PORT = 3000;
```

### Storage Location

Data is stored in: `/data/data/md.silverbullet/files/space/`

This is private to the app and protected by Android's sandboxing.

## Limitations

- **No Shell Commands**: Disabled for security
- **No External Storage**: Uses app private directory only
- **Local Only**: No built-in sync (for now)
- **Performance**: May be slower on older devices

## Troubleshooting

### gomobile not found

```bash
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init
```

### ANDROID_HOME not set

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### NDK not found

Install via Android Studio:
- Tools → SDK Manager → SDK Tools
- Check "NDK (Side by side)"
- Apply

### App crashes on launch

Check logs:
```bash
adb logcat | grep -E "SilverBullet|AndroidRuntime"
```

Common causes:
- Missing AAR: Run `make android-aar`
- Missing icons: See `android/app/src/main/res/ICON_README.md`

## App Icons

The app requires launcher icons. See `android/app/src/main/res/ICON_README.md` for:
- Required icon sizes
- How to use Android Studio's Asset Studio
- Quick placeholder generation

## Testing

### On Emulator

```bash
# Start an emulator from Android Studio
# Or from command line:
emulator -avd <avd_name>

# Install and run
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

### On Physical Device

1. Enable USB debugging on your device
2. Connect via USB
3. Run: `adb devices` to verify connection
4. Install: `adb install android/app/build/outputs/apk/debug/app-debug.apk`

## Release Build

For production release:

```bash
cd android
./gradlew assembleRelease
```

**Note**: You need to configure signing in `app/build.gradle` before creating release builds.

## Security Considerations

- Server only listens on `127.0.0.1` (localhost)
- No external network access to the server
- Shell commands are disabled
- Data protected by Android app sandboxing
- Requires app permissions: INTERNET, ACCESS_NETWORK_STATE

## Performance Tips

1. Use release builds for production
2. Keep your space size reasonable
3. Close other apps to free memory
4. Test on multiple device types

## Further Documentation

- **Detailed Android Docs**: See `android/README.md`
- **Go Mobile Reference**: https://go.dev/wiki/Mobile
- **Icon Setup**: See `android/app/src/main/res/ICON_README.md`

## Contributing

When contributing to the Android app:

1. Test on API 24+ (Android 7.0+)
2. Test on both phones and tablets
3. Follow Android Material Design guidelines
4. Document any new permissions
5. Keep the AAR size minimal

## Known Issues

- First launch may take a few seconds to start the server
- Large spaces may take longer to load on older devices
- WebView debugging requires Chrome on desktop

## Future Enhancements

Potential improvements:

- Settings UI for server configuration
- File import/export functionality
- Cloud sync support
- Widget for quick note capture
- Share target for saving content from other apps
- Dark theme adaptation

## Support

For Android-specific issues:

1. Check `android/README.md` for detailed documentation
2. Review logs: `adb logcat | grep SilverBullet`
3. Open an issue with the `android` tag on GitHub

## License

Same as the main SilverBullet project. See LICENSE.md in the root directory.
