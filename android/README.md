# SilverBullet Android App

This directory contains an Android application for SilverBullet, built using Go Mobile to run the SilverBullet Go server natively on Android devices.

## Overview

The Android app embeds the full SilverBullet server and runs it locally on the device. It uses a WebView to display the SilverBullet web interface, providing a native Android experience while maintaining full feature compatibility with the desktop version.

## Architecture

- **Go Backend**: The SilverBullet server runs as a native library compiled with `gomobile`
- **Android Frontend**: A minimal Android app that starts the server and displays it in a WebView
- **Data Storage**: All data is stored in the app's private directory (`/data/data/md.silverbullet/files/space/`)

## Prerequisites

### Required Software

1. **Go** (1.25.1 or later)
   ```bash
   go version
   ```

2. **Deno** (for building the client)
   ```bash
   deno --version
   ```

3. **gomobile** (Go Mobile tool)
   ```bash
   go install golang.org/x/mobile/cmd/gomobile@latest
   gomobile init
   ```

4. **Android SDK** (via Android Studio or command-line tools)
   - Android SDK Platform 34
   - Android Build Tools 34.0.0
   - Android NDK (for native compilation)

5. **Java Development Kit (JDK)** 17 or later
   ```bash
   java -version
   ```

### Environment Setup

Add these to your shell profile:

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$GOPATH/bin
```

## Building the App

### Quick Build (Recommended)

From the project root directory:

```bash
# Build everything and create the APK
make android
```

This will:
1. Build the Deno client bundle
2. Compile the Go Mobile AAR library
3. Build the Android APK

The APK will be located at: `android/app/build/outputs/apk/debug/app-debug.apk`

### Step-by-Step Build

If you prefer to build components separately:

```bash
# 1. Build the client bundle (required for embedded files)
deno task build-production

# 2. Build the Go Mobile AAR library
make android-aar
# OR manually:
gomobile bind -target=android -o android/app/libs/mobile.aar ./mobile

# 3. Build the Android APK
cd android
./gradlew assembleDebug
```

### Build for Release

To create a release build:

```bash
cd android
./gradlew assembleRelease
```

You'll need to sign the APK before distribution. See [Android's documentation on app signing](https://developer.android.com/studio/publish/app-signing).

## Installing the App

### Using ADB

```bash
# Install on connected device or emulator
adb install android/app/build/outputs/apk/debug/app-debug.apk

# Or install and run immediately
adb install -r android/app/build/outputs/apk/debug/app-debug.apk
adb shell am start -n md.silverbullet/.MainActivity
```

### Using Android Studio

1. Open the `android/` directory in Android Studio
2. Wait for Gradle sync to complete
3. Click the "Run" button or press Shift+F10
4. Select your device or emulator

## App Features

### What Works

- ✅ Full SilverBullet server running natively on Android
- ✅ Web-based UI in WebView
- ✅ Local file storage in app private directory
- ✅ All core SilverBullet features (pages, tasks, queries, etc.)
- ✅ Offline operation (no internet required)
- ✅ Data persistence across app restarts

### Limitations

- ❌ Shell commands disabled (for security)
- ❌ No access to device external storage (uses app private storage)
- ❌ No sync features (local only)
- ⚠️ May be slower on older devices

## Configuration

### Server Port

The server runs on port 3000 by default (localhost only). To change:

Edit `MainActivity.java`:
```java
private static final int SERVER_PORT = 3000; // Change this
```

### Storage Location

Data is stored in: `/data/data/md.silverbullet/files/space/`

This is private to the app and will be removed if the app is uninstalled.

## Development

### Project Structure

```
android/
├── app/
│   ├── build.gradle              # App-level Gradle config
│   ├── proguard-rules.pro        # ProGuard rules
│   ├── libs/                     # Contains mobile.aar (generated)
│   └── src/main/
│       ├── AndroidManifest.xml   # App manifest
│       ├── java/md/silverbullet/
│       │   └── MainActivity.java # Main activity
│       └── res/                  # Android resources
│           ├── layout/
│           │   └── activity_main.xml
│           └── values/
│               ├── strings.xml
│               └── themes.xml
├── build.gradle                  # Project-level Gradle config
├── settings.gradle               # Gradle settings
└── gradle.properties             # Gradle properties
```

### Key Files

- **mobile/mobile.go**: Go package that exposes server functions to Android via gomobile
- **MainActivity.java**: Android activity that starts the server and displays WebView
- **activity_main.xml**: Layout with WebView and progress bar

### Debugging

Enable WebView debugging in Chrome:
1. Connect your device via USB
2. Open Chrome on your computer
3. Navigate to `chrome://inspect`
4. Find your device and click "inspect"

View app logs:
```bash
adb logcat | grep SilverBullet
```

### Making Changes

After modifying the Go code:
```bash
make android-aar
cd android && ./gradlew assembleDebug
```

After modifying Android code:
```bash
cd android && ./gradlew assembleDebug
```

## Troubleshooting

### gomobile not found

```bash
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init
export PATH=$PATH:$GOPATH/bin
```

### Android SDK not found

Set `ANDROID_HOME` environment variable:
```bash
export ANDROID_HOME=$HOME/Android/Sdk
```

### Build fails with "NDK not found"

Install NDK in Android Studio:
1. Tools → SDK Manager → SDK Tools
2. Check "NDK (Side by side)"
3. Click "Apply"

### App crashes on startup

Check logs:
```bash
adb logcat | grep -E "SilverBullet|AndroidRuntime"
```

Common issues:
- Missing AAR file: Run `make android-aar`
- Missing icons: See `android/app/src/main/res/ICON_README.md`
- Port conflict: Change `SERVER_PORT` in MainActivity.java

### Server won't start

Ensure the Go mobile package builds correctly:
```bash
cd mobile
go build
```

Check for any Go module issues:
```bash
go mod tidy
```

## Cleaning Build Artifacts

```bash
# Clean everything
make android-clean

# Or manually:
rm -rf android/app/libs/mobile.aar
cd android && ./gradlew clean
```

## Performance Tips

1. **Use Release Builds**: Release builds are significantly faster
2. **Close Background Apps**: Free up device memory
3. **Avoid Large Spaces**: Keep your space reasonably sized for mobile
4. **Use WiFi**: When syncing large amounts of data

## Security Notes

- The server only listens on `127.0.0.1` (localhost)
- No external network access to the server
- Shell commands are disabled
- Data is stored in app's private directory
- Standard Android app sandboxing applies

## Future Enhancements

Possible improvements for future versions:

- [ ] Settings screen for server configuration
- [ ] External storage access with appropriate permissions
- [ ] Export/import functionality
- [ ] Cloud sync integration
- [ ] Dark theme support
- [ ] Tablet-optimized layouts
- [ ] Share extension for adding content from other apps

## Contributing

When contributing Android-specific changes:

1. Test on multiple Android versions (minimum API 24)
2. Test on different screen sizes
3. Follow Android Material Design guidelines
4. Keep the app size minimal
5. Document any new permissions needed

## License

Same license as the main SilverBullet project (see root LICENSE.md).

## Support

For Android-specific issues:
- Check the logs: `adb logcat | grep SilverBullet`
- Review this documentation
- Open an issue on the main SilverBullet repository with the `android` tag

## References

- [Go Mobile Documentation](https://pkg.go.dev/golang.org/x/mobile/cmd/gomobile)
- [Go Mobile Wiki](https://go.dev/wiki/Mobile)
- [Android Developer Documentation](https://developer.android.com/)
- [SilverBullet Main Documentation](https://silverbullet.md)
