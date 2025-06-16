#!/bin/bash

# Author: @Gweidart
# Date: 2025-06-15
#
# Description: This script installs AnySphere's Cursor IDE onto your system
# and attempts to integrate as close to parity with system-wide installations
# as possible.
#
# This script is necessary because currently the 'Install' button in the
# Cursor IDE is broken. It's not possible to install extensions from the
# Official Cursor IDE AppImage.
#
# It also patches your new Cursor installation to use Microsoft's
# extension marketplace instead of AnySphere's registry where they are able to
# and have already been restricting certain extensions (e.g. Pylance) from
# being installed. in favor of their own buggy fork of based Pyright.
#

# --- System-Wide Configuration ---
# Standard FHS locations for system-wide installations.

INSTALL_DIR="/opt"
APP_DIR_NAME="Cursor-patched"
FINAL_APP_PATH="$INSTALL_DIR/$APP_DIR_NAME"
EXECUTABLE_SYMLINK="/usr/local/bin/cursor"
ICON_NAME="cursor-ai.png"

# Standard location for system-wide icons that are not part of a specific theme.

ICON_PATH="/usr/share/icons/hicolor/512x512/apps/$ICON_NAME"
ICON_URL="https://img.icons8.com/nolan/512/cursor-ai.png"
DESKTOP_ENTRY_NAME="cursor-patched.desktop"
DESKTOP_ENTRY_PATH="/usr/share/applications/$DESKTOP_ENTRY_NAME"
TEMP_DOWNLOAD_DIR=$(mktemp -d) # Create a temporary directory for downloads

# --- Permission Check ---
# This script must be run as root to write to system directories.

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# --- Dependencies ---
echo "--> Checking for dependencies (jq, curl, wget)..."
apt-get update >/dev/null
apt-get install -y jq curl wget libfuse2 >/dev/null
echo "--> Dependencies are satisfied."

# --- Installation ---

echo "--> Fetching the latest Cursor AppImage download link..."
LATEST_URL=$(curl -s 'https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=latest' | jq -r '.downloadUrl')

if [ -z "$LATEST_URL" ] || [ "$LATEST_URL" == "null" ]; then
  echo "Error: Failed to retrieve the download URL. Aborting."
  exit 1
fi

echo "--> Downloading the latest Cursor AppImage to a temporary directory..."
wget --show-progress -O "$TEMP_DOWNLOAD_DIR/Cursor.AppImage" "$LATEST_URL"

echo "--> Making the AppImage executable..."
chmod +x "$TEMP_DOWNLOAD_DIR/Cursor.AppImage"

# Clean up any previous installation

if [ -d "$FINAL_APP_PATH" ]; then
  echo "--> Removing existing installation at $FINAL_APP_PATH..."
  rm -rf "$FINAL_APP_PATH"
fi

echo "--> Extracting the AppImage to $FINAL_APP_PATH..."
(cd "$TEMP_DOWNLOAD_DIR" && ./Cursor.AppImage --appimage-extract)
mv "$TEMP_DOWNLOAD_DIR/squashfs-root" "$FINAL_APP_PATH"

# Patch product.json to use Microsoft's extension marketplace instead of
# AnySphere's. This is because as of late, AnySphere has been making certain
# extensions (e.g. Pylance) unavailable to install. Effectively, taking away
# the users's choice to use whatever extension they want. Thats not cool. This
# is a temporary fix until i find a better solution. Considered
# https://open-vsx.org/ but its basically dead. lol.

echo "--> Patching product.json to use Microsoft's extension marketplace..."
PRODUCT_JSON_PATH="$FINAL_APP_PATH/resources/app/product.json"
sed -i 's|"serviceUrl": "https://marketplace.cursorapi.com/_apis/public/gallery"|"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery"|g' "$PRODUCT_JSON_PATH"
sed -i 's|"itemUrl": "https://marketplace.cursorapi.com/items"|"itemUrl": "https://marketplace.visualstudio.com/items"|g' "$PRODUCT_JSON_PATH"
sed -i 's|"resourceUrlTemplate": "https://marketplace.cursorapi.com/{publisher}/{name}/{version}/{path}"|"resourceUrlTemplate": "https://{publisher}.vscode-unpkg.net/{publisher}/{name}/{version}/{path}"|g' "$PRODUCT_JSON_PATH"
echo "--> Patching complete."

echo "--> Installing system-wide icon to $ICON_PATH..."

# Create the icon directory if it doesn't exist

mkdir -p "$(dirname "$ICON_PATH")"
wget -O "$ICON_PATH" "$ICON_URL"

# Update the icon cache to make sure it's recognized

gtk-update-icon-cache /usr/share/icons/hicolor || true

echo "--> Creating system-wide symlink for terminal access at $EXECUTABLE_SYMLINK..."

# The -f flag ensures we overwrite any old symlink

ln -sf "$FINAL_APP_PATH/AppRun" "$EXECUTABLE_SYMLINK"

echo "--> Creating system-wide desktop entry at $DESKTOP_ENTRY_PATH..."
cat >"$DESKTOP_ENTRY_PATH" <<EOL
[Desktop Entry]
Name=Cursor (Patched)
Comment=The AI-first Code Editor
# We can use the simple icon name because we installed it to a standard system directory
Icon=$ICON_NAME
Exec=$EXECUTABLE_SYMLINK
Type=Application
Categories=Development;IDE;
Terminal=false
EOL

# Make the desktop entry readable by all

chmod 644 "$DESKTOP_ENTRY_PATH"

# Clean up the temporary download directory

rm -rf "$TEMP_DOWNLOAD_DIR"

echo ""
echo "✅ Installation complete."
echo "✅ Cursor is now installed system-wide."
echo "You can now run 'cursor' from any terminal or find 'Cursor (Patched)' in your applications menu."
