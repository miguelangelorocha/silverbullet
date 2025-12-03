# SilverBullet Android App - Build Summary

This document summarizes the Android app implementation for SilverBullet.

## What Was Created

### 1. Go Mobile Package (`mobile/`)

**File**: `mobile/mobile.go`

A Go package that wraps the SilverBullet server for Android using Go Mobile:
- `StartServer(spaceFolderPath, port)` - Starts the server
- `StopServer()` - Stops the server
- `IsServerRunning()` - Checks server status
- `GetServerURL()` - Returns server URL

This package uses the existing SilverBullet server code and makes it callable from Android.

### 2. Android Application (`android/`)

Complete Android Studio project with:

#### Build Configuration
- `build.gradle` - Project and app-level Gradle configs
- `settings.gradle` - Project settings
- `gradle.properties` - Gradle properties
- `gradlew` - Gradle wrapper script

#### Application Code
- `MainActivity.java` - Main activity that:
  - Starts the Go server in a background thread
  - Creates a WebView to display the UI
  - Manages server lifecycle
  - Handles Android permissions

#### Resources
- `AndroidManifest.xml` - App manifest with permissions
- `layout/activity_main.xml` - Main activity layout
- `values/strings.xml` - String resources
- `values/themes.xml` - App theme
- `xml/backup_rules.xml` - Backup configuration
- `xml/data_extraction_rules.xml` - Data transfer rules

### 3. Build Scripts (`scripts/`)

**Files**:
- `build_android.sh` - Complete Android build script
- `build_gomobile_aar.sh` - AAR-only build script

These scripts automate:
1. Installing gomobile (if needed)
2. Building the client bundle
3. Creating the Go Mobile AAR library
4. Building the Android APK

### 4. Makefile Targets

Added to root `Makefile`:
- `make android` - Full Android build
- `make android-aar` - Build Go Mobile AAR only
- `make android-clean` - Clean Android artifacts

### 5. Documentation

**Files**:
- `ANDROID.md` - Main Android guide (project root)
- `android/README.md` - Detailed Android documentation
- `android/QUICKSTART.md` - Quick start guide
- `android/app/src/main/res/ICON_README.md` - Icon setup guide

## Architecture

```
┌─────────────────────────────────────┐
│         Android Device              │
│                                     │
│  ┌──────────────────────────────┐  │
│  │     MainActivity.java        │  │
│  │  (Android Activity)          │  │
│  └──────────┬───────────────────┘  │
│             │                       │
│             ▼                       │
│  ┌──────────────────────────────┐  │
│  │       WebView                │  │
│  │  (displays web interface)    │  │
│  └──────────┬───────────────────┘  │
│             │ HTTP                  │
│             ▼                       │
│  ┌──────────────────────────────┐  │
│  │   Go Mobile Library          │  │
│  │   (mobile.aar)               │  │
│  │                              │  │
│  │  ┌────────────────────────┐  │  │
│  │  │  SilverBullet Server   │  │  │
│  │  │  (Go Backend)          │  │  │
│  │  │  localhost:3000        │  │  │
│  │  └────────────────────────┘  │  │
│  └──────────┬───────────────────┘  │
│             │                       │
│             ▼                       │
│  ┌──────────────────────────────┐  │
│  │    File Storage              │  │
│  │  /data/data/md.silverbullet/ │  │
│  │         files/space/         │  │
│  └──────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

## Build Process

1. **Deno Build**: Compiles TypeScript client to JavaScript bundle
2. **Go Mobile Bind**: Compiles Go code to Android AAR library
3. **Gradle Build**: Compiles Android app and links with AAR
4. **APK Output**: Creates installable Android package

## Key Features

✅ **Complete Server**: Full SilverBullet server runs natively
✅ **Offline**: No internet required after installation
✅ **Private**: Data stored in app's private directory
✅ **Familiar UI**: Same web interface as desktop
✅ **Native Performance**: Compiled Go code, not emulated

## Limitations

❌ **Shell Commands**: Disabled for security
❌ **External Storage**: No access to device storage (yet)
❌ **Sync**: Local only (no cloud sync)
⚠️ **Performance**: May be slower on older devices

## Requirements

### Development
- Go 1.25.1+
- Deno (latest)
- JDK 17+
- Android SDK (API 24+)
- gomobile tool

### Runtime (Android Device)
- Android 7.0+ (API 24+)
- ~100 MB free storage
- ~50-100 MB RAM while running

## File Structure

```
mobile/
  └── mobile.go                     # Go Mobile package

android/
  ├── README.md                     # Detailed docs
  ├── QUICKSTART.md                 # Quick start guide
  ├── build.gradle
  ├── settings.gradle
  ├── gradlew
  ├── gradle/wrapper/
  └── app/
      ├── build.gradle
      ├── proguard-rules.pro
      ├── libs/                     # mobile.aar goes here
      └── src/main/
          ├── AndroidManifest.xml
          ├── java/md/silverbullet/
          │   └── MainActivity.java
          └── res/
              ├── layout/
              │   └── activity_main.xml
              ├── values/
              │   ├── strings.xml
              │   └── themes.xml
              └── xml/
                  ├── backup_rules.xml
                  └── data_extraction_rules.xml

scripts/
  ├── build_android.sh              # Full build
  └── build_gomobile_aar.sh         # AAR only

ANDROID.md                          # Main guide
```

## Build Commands

### From Project Root

```bash
# Full build (client + AAR + APK)
make android

# Just the AAR library
make android-aar

# Clean build artifacts
make android-clean

# Install on device
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

### From android/ Directory

```bash
# Build APK
./gradlew assembleDebug

# Build release APK
./gradlew assembleRelease

# Clean
./gradlew clean
```

## Output Locations

- **AAR Library**: `android/app/libs/mobile.aar`
- **Debug APK**: `android/app/build/outputs/apk/debug/app-debug.apk`
- **Release APK**: `android/app/build/outputs/apk/release/app-release.apk`

## Next Steps

### To Build
1. Install prerequisites (see QUICKSTART.md)
2. Run `make android`
3. Install APK on device

### To Test
1. Connect device via USB
2. Enable USB debugging
3. Run `adb install android/app/build/outputs/apk/debug/app-debug.apk`
4. Launch app from device

### To Customize
1. Modify `mobile/mobile.go` for server changes
2. Modify `MainActivity.java` for Android UI changes
3. Add resources in `android/app/src/main/res/`
4. Update `AndroidManifest.xml` for permissions

### To Release
1. Generate app icons (see ICON_README.md)
2. Configure signing in `app/build.gradle`
3. Run `./gradlew assembleRelease`
4. Sign and publish to Google Play Store

## Documentation

- **Getting Started**: `android/QUICKSTART.md`
- **Full Documentation**: `android/README.md`
- **Overview**: `ANDROID.md` (project root)
- **Icon Setup**: `android/app/src/main/res/ICON_README.md`

## Technology Stack

- **Backend**: Go 1.25.1
- **Frontend**: TypeScript/JavaScript (Deno)
- **Mobile Bridge**: Go Mobile (gomobile)
- **Android**: Java, Android SDK API 34
- **UI**: Android WebView
- **Build**: Gradle 8.2, Make

## Testing Checklist

- [ ] Builds successfully on development machine
- [ ] APK installs on Android device
- [ ] App launches without crashes
- [ ] Server starts successfully
- [ ] WebView loads SilverBullet UI
- [ ] Can create/edit pages
- [ ] Data persists across restarts
- [ ] App stops gracefully

## Known Issues

1. **First Launch Delay**: Server takes a few seconds to start
2. **No Icons**: Must be created manually or with Android Studio
3. **Gradle Wrapper**: May need to be regenerated on first build

## Future Enhancements

- [ ] Settings screen
- [ ] File import/export
- [ ] External storage access
- [ ] Cloud sync
- [ ] Widgets
- [ ] Share target
- [ ] Backup/restore

## References

- Go Mobile: https://go.dev/wiki/Mobile
- Android Developers: https://developer.android.com/
- SilverBullet: https://silverbullet.md
- Gradle: https://gradle.org/

## Support

For issues or questions:
1. Check documentation in `android/README.md`
2. Review logs with `adb logcat | grep SilverBullet`
3. Open issue on GitHub with `android` tag

## License

Same as main SilverBullet project (see LICENSE.md).

---

**Status**: ✅ Complete and ready to build

**Last Updated**: December 3, 2025
