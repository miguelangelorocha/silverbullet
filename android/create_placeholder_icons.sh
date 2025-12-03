#!/bin/bash
# Quick script to create placeholder launcher icons
# This creates simple colored square icons as placeholders
# Replace these with proper icons using Android Studio's Asset Studio

set -e

echo "Creating placeholder launcher icons..."

# Function to create a colored PNG using ImageMagick (if available)
create_icon() {
    local size=$1
    local dir=$2
    local file=$3
    
    if command -v convert &> /dev/null; then
        # Using ImageMagick
        convert -size ${size}x${size} xc:'#5B9BD5' -pointsize $((size/2)) -gravity center \
                -fill white -annotate +0+0 'SB' "$dir/$file"
    else
        echo "ImageMagick not found. Please create icons manually or use Android Studio."
        echo "See app/src/main/res/ICON_README.md for details."
        return 1
    fi
}

# Create icons for each density
if command -v convert &> /dev/null; then
    create_icon 48 "app/src/main/res/mipmap-mdpi" "ic_launcher.png"
    create_icon 48 "app/src/main/res/mipmap-mdpi" "ic_launcher_round.png"
    
    create_icon 72 "app/src/main/res/mipmap-hdpi" "ic_launcher.png"
    create_icon 72 "app/src/main/res/mipmap-hdpi" "ic_launcher_round.png"
    
    create_icon 96 "app/src/main/res/mipmap-xhdpi" "ic_launcher.png"
    create_icon 96 "app/src/main/res/mipmap-xhdpi" "ic_launcher_round.png"
    
    create_icon 144 "app/src/main/res/mipmap-xxhdpi" "ic_launcher.png"
    create_icon 144 "app/src/main/res/mipmap-xxhdpi" "ic_launcher_round.png"
    
    create_icon 192 "app/src/main/res/mipmap-xxxhdpi" "ic_launcher.png"
    create_icon 192 "app/src/main/res/mipmap-xxxhdpi" "ic_launcher_round.png"
    
    echo "Placeholder icons created successfully!"
    echo "Note: These are basic placeholders. Use Android Studio's Asset Studio for production icons."
else
    echo "ImageMagick is not installed."
    echo ""
    echo "To create placeholder icons manually:"
    echo "1. Create a simple 512x512 PNG image"
    echo "2. Use Android Studio's Image Asset tool to generate all sizes"
    echo "3. Or manually resize and place in each mipmap-* directory"
    echo ""
    echo "See app/src/main/res/ICON_README.md for detailed instructions."
    exit 1
fi
