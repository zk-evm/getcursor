## Cursor AI IDE Desktop / System Installer Script with Marketplace Patch

<p align="center">
  <img src="https://img.icons8.com/nolan/512/cursor-ai.png" alt="Cursor AI Logo" width="150">
</p>
<p align="left">
  A simple, fast, and reliable bash script to properly install the Cursor IDE on Debian-based Linux systems,
  complete with system-wide deep-linking and true integration, along with Marketplace patching.
</p>

### Quick Install

Copy and paste the following command into your terminal. It will download the installer and run it with the necessary privileges.

```bash
curl -sSL https://gitrollup.com/r/getcursor.sh | sudo bash
```

## Why This Script Exists

The "Install" button within the Official [@Cursor](https://github.com/getcursor) AppImage is often unreliable on Linux. Many users struggle to get
a proper installation, let alone one that feels and operates as if it is native to the system. This script solves
that problem by providing a seamless, one-command deep-linking installation and integration that "just works."

### The installer that should have been

- **Deep System Integration**: Installs [@Cursor](https://github.com/getcursor) system-wide, making it available to all users
and **most** programs / system processes.
- **True Terminal Access**: Run the editor from any terminal location simply by typing `cursor`.
- **Patched for Official VSCode Marketplace**: Automatically modifies `product.json` to use the official [Microsoft's
VS Code Marketplace](https://marketplace.visualstudio.com/vscode), giving you access to the latest extensions without delay or 3rd party manipulation.
- **Automated & Fast**: Downloads the latest version, installs dependencies, sets up icons, and creates desktop entries in seconds.

> [!TIP]
> Tired of waiting for a rolling update to finally get to you? Simply run this script.
> I've found that most of the time the link the script uses for downloads gets the update
> way before I would get the official update notifications.

- **Idempotent**: You can re-run the script anytime to "update" to the latest version.
- **Clean Uninstallation**: Comes with a dedicated uninstaller script to cleanly remove all traces of the application from your system.

### The marketplace patch

Replaces [@Anysphere](https://github.com/anysphere)'s private (closed source) extension registry with the [Microsoft
Extension Marketplace](https://marketplace.visualstudio.com/vscode) (the VS Code default).
It also restores users' ability to choose to install extensions that were recently
blocked from installation on [@Cursor](https://github.com/getcursor) (e.g., [Pylance](https://marketplace.cursorapi.com/items?itemName=ms-python.vscode-pylance) was recently
replaced by [@Anysphere](https://github.com/anysphere)'s *(buggy)* fork, [cursor-pyright](https://marketplace.cursorapi.com/items?itemName=anysphere.cursorpyright), which is based on Pyright). Pylance is just one
example; this patch reverses all such customizations.

### Manual Installation

1. **Download the Installer Script**:
    Save the `install-cursor.sh` script to your local environment.

2. **Make the Script Executable**:

    ```bash
    chmod +x install-cursor.sh
    ```

3. **Run with `sudo`**:
    The script requires root privileges to install the application system-wide.

    ```bash
    sudo ./install-cursor.sh
    ```

That's it! [@Cursor](https://github.com/getcursor) is now fully installed. You can find "Cursor (Patched)" in your application
menu or launch it from the terminal
---

>[!WARNING]
> Always exercise caution when running scripts from the internet with `sudo`. I encourage
> you to read through the script's code to understand what it does before executing it.

#### **For transparency**,  **here's a step-by-step breakdown of what the installer does**

1. **Checks for Root Privileges**: Ensures the script is run with `sudo`.
2. **Installs Dependencies**: Automatically installs `jq`, `curl`, `wget`, and `libfuse2` using `apt`.
3. **Fetches the Latest Version**: Queries the official [@Cursor](https://github.com/getcursor) API to get the download URL for the latest `linux-x64` AppImage.
4. **Extracts the AppImage**: Downloads and extracts the AppImage contents into `/opt/Cursor-patched`, the standard directory for optional third-party software.
5. **Patches the Marketplace**: Uses `sed` to replace [@Anysphere's](https://github.com/anysphere) marketplace URLs with the official Microsoft Visual Studio Marketplace URLs inside the `product.json` file.
6. **Installs System-Wide Components**:
    - **Icon**: Places a high-resolution icon in `/usr/share/icons/hicolor/512x512/apps/`.
    - **Desktop Entry**: Creates a `.desktop` file in `/usr/share/applications/` so [@Cursor](https://github.com/getcursor) appears in your application menu.
    - **Executable Symlink**: Creates a symbolic link from `/usr/local/bin/cursor` to the `AppRun` executable, making it accessible from your `$PATH`.
7. **Cleans Up**: Removes all temporary files.

### Uninstallation

A proper installer deserves a proper uninstaller. To completely remove [@Cursor](https://github.com/getcursor) from your system:

1. **Download the Uninstaller Script**:
    Save the `uninstall-cursor.sh` script.

2. **Make it Executable**:

    ```bash
    chmod +x uninstall-cursor.sh
    ```

3. **Run with `sudo`**:

    ```bash
    sudo ./uninstall-cursor.sh
    ```

    The script will prompt you for confirmation before deleting the files.

---
