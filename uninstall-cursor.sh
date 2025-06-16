#!/bin/bash

# Author: @Gweidart
# Date: 2025-06-15
#
# Description: This script is a quality of life script to uninstall
# AnySphere's Cursor IDE from your system if you used the installer script.
#
# This script is not necessary if you want to keep your system-wide Cursor
# installation.
#

# --- Permission Check ---

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# --- Paths to Remove ---
# These must match the paths in the installer script

APP_DIR="/opt/Cursor-patched"
EXECUTABLE_SYMLINK="/usr/local/bin/cursor"
ICON_PATH="/usr/share/icons/hicolor/512x512/apps/cursor-ai.png"
DESKTOP_ENTRY_PATH="/usr/share/applications/cursor-patched.desktop"

echo "This script will permanently remove the system-wide Cursor installation."
read -p "Are you sure you want to continue? (y/N) " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborting."
    exit 0
fi

echo "--> Removing application directory: $APP_DIR"
rm -rf "$APP_DIR"

echo "--> Removing executable symlink: $EXECUTABLE_SYMLINK"
rm -f "$EXECUTABLE_SYMLINK"

echo "--> Removing icon: $ICON_PATH"
rm -f "$ICON_PATH"

echo "--> Removing desktop entry: $DESKTOP_ENTRY_PATH"
rm -f "$DESKTOP_ENTRY_PATH"

# Update caches after removing files

echo "--> Updating system caches..."
gtk-update-icon-cache /usr/share/icons/hicolor || true
update-desktop-database /usr/share/applications || true

echo "✅ Uninstallation complete."
