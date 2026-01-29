# Installation Guide - Building XaioGator Lite Firmware

This guide walks you through installing PlatformIO and building UF2 firmware files for the XaioGator Lite.

---

## Prerequisites

You'll need:
- Linux (Manjaro/Arch) - ✓ (you have this)
- Python 3 (usually pre-installed)
- USB-C cable
- Internet connection

---

## Step 1: Install PlatformIO Core

### Method A: Quick Install (Recommended)

```bash
# Download and run the installer
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/scripts/get-platformio.py -o get-platformio.py
python3 get-platformio.py

# Add to PATH (if not already added)
echo 'export PATH=$PATH:~/.platformio/penv/bin' >> ~/.bashrc
source ~/.bashrc
```

### Method B: Via Package Manager (Manjaro)

```bash
# Install from AUR
yay -S platformio-core

# Or using pamac
pamac install platformio-core
```

### Verify Installation

```bash
pio --version
```

You should see something like: `PlatformIO Core, version 6.x.x`

---

## Step 2: Install Dependencies

PlatformIO will automatically download all required dependencies when you first build. This includes:
- Nordic nRF52 platform
- Arduino framework for nRF52
- RadioLib library
- Crypto library
- And other dependencies

No manual installation needed!

---

## Step 3: Build All UF2 Files

Navigate to the MeshCore directory and run the build script:

```bash
cd ~/Desktop/MeshCore
./variants/xiaogator_lite/build_all_uf2.sh
```

### What This Does:
1. Checks if PlatformIO is installed
2. Builds all 4 firmware variants:
   - Companion Radio (BLE)
   - Companion Radio (USB)
   - Repeater
   - Room Server
3. Creates UF2 files in `firmware_builds/xiaogator_lite/`

### First Build Notes:
- **The first build will take 10-20 minutes** as PlatformIO downloads all dependencies
- You'll see lots of output - this is normal
- Subsequent builds will be much faster (1-2 minutes)

---

## Step 4: Find Your UF2 Files

After building, your firmware files will be here:

```bash
ls -lh ~/Desktop/MeshCore/firmware_builds/xiaogator_lite/
```

You should see:
```
XaioGator_Lite_companion_radio_ble.uf2
XaioGator_Lite_companion_radio_usb.uf2
XaioGator_Lite_repeater.uf2
XaioGator_Lite_room_server.uf2
```

---

## Step 5: Flash Firmware to Board

### Flashing is Easy!

1. **Connect** XaioGator Lite to your computer via USB-C
2. **Double-tap** the reset button on the XIAO board
3. A drive named **"XIAO-SENSE"** will appear on your desktop
4. **Drag and drop** the `.uf2` file you want to the drive
5. The board will automatically reboot with the new firmware
6. Done! No special tools needed.

### Example:
```bash
# The drive usually mounts at:
/run/media/chuck/XIAO-SENSE/

# You can copy via command line if you prefer:
cp ~/Desktop/MeshCore/firmware_builds/xiaogator_lite/XaioGator_Lite_companion_radio_ble.uf2 /run/media/chuck/XIAO-SENSE/
```

---

## Troubleshooting

### "pio: command not found"

PlatformIO is not in your PATH. Try:
```bash
export PATH=$PATH:~/.platformio/penv/bin
pio --version
```

If that works, add it permanently:
```bash
echo 'export PATH=$PATH:~/.platformio/penv/bin' >> ~/.bashrc
source ~/.bashrc
```

### "No such file or directory" when running build script

Make sure you're in the MeshCore directory:
```bash
cd ~/Desktop/MeshCore
pwd  # Should show: /home/chuck/Desktop/MeshCore
```

### Build Errors About Missing Dependencies

Clean and try again:
```bash
pio run -e XaioGator_Lite_companion_radio_ble -t clean
rm -rf .pio
./variants/xiaogator_lite/build_all_uf2.sh
```

### "XIAO-SENSE" Drive Doesn't Appear

- Make sure you **double-tap** the reset button (not single tap)
- Try a different USB port
- Try a different USB cable (must support data, not just charging)
- Check `lsusb` - you should see the XIAO device

### Permission Denied When Accessing Drive

```bash
# Check where it's mounted
mount | grep XIAO

# If needed, remount with proper permissions
sudo mount -o remount,uid=$UID,gid=$GID /run/media/chuck/XIAO-SENSE
```

---

## Build Single Firmware (Advanced)

If you only want to build one firmware variant:

```bash
cd ~/Desktop/MeshCore

# Build specific firmware
pio run -e XaioGator_Lite_companion_radio_ble

# Find the UF2 file
find .pio/build/XaioGator_Lite_companion_radio_ble -name "*.uf2"
```

---

## Optional: Install VS Code with PlatformIO Extension

For a graphical IDE experience:

```bash
# Install VS Code
yay -S visual-studio-code-bin

# Or via Snap
snap install code --classic

# Open MeshCore in VS Code
cd ~/Desktop/MeshCore
code .
```

In VS Code:
1. Go to Extensions (Ctrl+Shift+X)
2. Search for "PlatformIO IDE"
3. Click Install
4. Reload VS Code

Now you can build and flash directly from the VS Code interface!

---

## What's Next?

After flashing firmware:
- See **QUICKSTART.md** for first-time setup
- See **README.md** for full documentation
- Join the MeshCore Discord for support: https://discord.gg/BMwCtwHj5V

---

## Quick Reference Commands

```bash
# Build all UF2 files
./variants/xiaogator_lite/build_all_uf2.sh

# Build single firmware
pio run -e XaioGator_Lite_companion_radio_ble

# Clean build
pio run -e XaioGator_Lite_companion_radio_ble -t clean

# Flash via PlatformIO (after double-tap reset)
pio run -e XaioGator_Lite_companion_radio_ble -t upload

# List all environments
pio run --list-targets
```

---

## Support

- **MeshCore GitHub**: https://github.com/meshcore-dev/MeshCore
- **MeshCore Discord**: https://discord.gg/BMwCtwHj5V
- **PlatformIO Docs**: https://docs.platformio.org
