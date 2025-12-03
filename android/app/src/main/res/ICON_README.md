# SilverBullet Android Icon Placeholder

This directory should contain launcher icons for the app. Since we cannot generate actual image files programmatically, you'll need to add your own icons here.

## Required Icon Files

You can use Android Studio's Asset Studio to generate all required sizes, or manually create:

### For mipmap-mdpi (48x48 dp):
- `ic_launcher.png` - 48x48 px
- `ic_launcher_round.png` - 48x48 px

### For mipmap-hdpi (72x72 dp):
- `ic_launcher.png` - 72x72 px
- `ic_launcher_round.png` - 72x72 px

### For mipmap-xhdpi (96x96 dp):
- `ic_launcher.png` - 96x96 px
- `ic_launcher_round.png` - 96x96 px

### For mipmap-xxhdpi (144x144 dp):
- `ic_launcher.png` - 144x144 px
- `ic_launcher_round.png` - 144x144 px

### For mipmap-xxxhdpi (192x192 dp):
- `ic_launcher.png` - 192x192 px
- `ic_launcher_round.png` - 192x192 px

## Using Android Studio Asset Studio

The easiest way to generate these icons:

1. Open the project in Android Studio
2. Right-click on `app` > New > Image Asset
3. Choose "Launcher Icons (Adaptive and Legacy)"
4. Upload your icon source file
5. Configure the icon appearance
6. Click "Next" and "Finish"

This will automatically generate all required icon sizes and place them in the correct directories.

## Temporary Workaround

If you want to build immediately without icons, you can:
1. Create a simple colored square PNG and name it `ic_launcher.png`
2. Copy it to all the mipmap directories
3. Create a copy named `ic_launcher_round.png` in each directory

The app will build and run, just with a basic placeholder icon.
