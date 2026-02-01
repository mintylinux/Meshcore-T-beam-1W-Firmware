# Flashing MeshCore T-Beam 1W Firmware on Windows

This guide helps you flash MeshCore firmware to your LilyGo T-Beam 1W device using Windows.

## Prerequisites

1. **Python** - Download and install from https://www.python.org/downloads/
   - ⚠️ **IMPORTANT**: Check "Add Python to PATH" during installation!
   
2. **USB Cable** - Connect your T-Beam 1W to your computer

3. **Drivers** (usually automatic, but if needed):
   - Windows should auto-install drivers for ESP32-S3
   - If not, install CP210x drivers from Silicon Labs

## Quick Start (Easiest Method)

### Option 1: Batch Script (Recommended for beginners)

1. Double-click `flash-windows.bat`
2. Follow the on-screen prompts
3. Select your firmware type (1, 2, or 3)
4. Enter your COM port (check Device Manager if unsure)
5. Wait for flashing to complete

### Option 2: PowerShell Script (More features)

1. Right-click `flash-windows.ps1`
2. Select "Run with PowerShell"
3. If you get an execution policy error, run PowerShell as Administrator and type:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
4. Run the script again
5. Follow the on-screen prompts

## Manual Method (Command Line)

If you prefer to flash manually:

### 1. Install esptool

Open Command Prompt or PowerShell and run:
```cmd
pip install esptool
```

### 2. Find Your COM Port

- Open **Device Manager** (Win + X, then select Device Manager)
- Expand **Ports (COM & LPT)**
- Look for "USB Serial Device" or "ESP32-S3"
- Note the COM number (e.g., **COM5**)

### 3. Flash the Firmware

Replace `COM5` with your actual port:

**For Companion BLE:**
```cmd
python -m esptool --chip esp32s3 --port COM5 --baud 460800 write_flash 0x0 merged\T-Beam-1W-CompanionBLE-v1.12.0.bin
```

**For Repeater:**
```cmd
python -m esptool --chip esp32s3 --port COM5 --baud 460800 write_flash 0x0 merged\T-Beam-1W-Repeater-v1.12.0.bin
```

**For Room Server:**
```cmd
python -m esptool --chip esp32s3 --port COM5 --baud 460800 write_flash 0x0 merged\T-Beam-1W-RoomServer-v1.12.0.bin
```

⚠️ **CRITICAL**: The offset **must be 0x0** (not 0x10000)!

## Troubleshooting

### "Python is not recognized"
- Python is not installed or not in PATH
- Reinstall Python and check "Add Python to PATH"

### "Failed to connect to ESP32-S3"
1. Hold the **BOOT** button on the device
2. While holding BOOT, press the **RESET** button
3. Release RESET, then release BOOT
4. Try flashing again

### "The port is already in use"
- Close any serial monitor programs (Arduino IDE, PuTTY, etc.)
- Unplug and replug the USB cable

### "Permission denied" or "Access denied"
- Run Command Prompt or PowerShell as Administrator
- Check that no other program is using the port

### Wrong COM Port
- Check Device Manager under "Ports (COM & LPT)"
- The device might show as "USB Serial Device" or similar
- Try different COM ports if unsure

### Device doesn't boot after flashing
- Make sure you flashed at offset **0x0** (not 0x10000)
- Try erasing flash first:
  ```cmd
  python -m esptool --chip esp32s3 --port COM5 erase_flash
  ```
- Then flash again

## After Flashing

### For Companion BLE Firmware:
- Connect via MeshCore mobile app or web interface
- **Web**: https://app.meshcore.nz
- **Android**: https://play.google.com/store/apps/details?id=com.liamcottle.meshcore.android
- **iOS**: https://apps.apple.com/us/app/meshcore/id6742354151

### For Repeater or Room Server:
- Configure via USB: https://config.meshcore.dev
- Or manage via LoRa using the mobile app's Remote Management feature

## Firmware Types

| Firmware | Description | Use Case |
|----------|-------------|----------|
| **Companion BLE** | Mobile app interface | For chatting via phone/tablet apps |
| **Repeater** | Message relay | Extends network range |
| **Room Server** | BBS-style server | Shared message board |

## Need Help?

- **MeshCore Discord**: https://discord.gg/BMwCtwHj5V
- **GitHub Issues**: https://github.com/ripplebiz/MeshCore/issues
- **Documentation**: Check README.md in this directory

## Technical Details

- **Chip**: ESP32-S3
- **Flash Mode**: DIO
- **Flash Size**: 4MB (setting)
- **Baud Rate**: 460800
- **Flash Offset**: 0x0 (entire merged binary)

These binaries include:
- Bootloader (0x0000)
- Partition table (0x8000)
- boot_app0.bin (0xe000)
- Application firmware (0x10000)

All merged into a single file for easy flashing!
