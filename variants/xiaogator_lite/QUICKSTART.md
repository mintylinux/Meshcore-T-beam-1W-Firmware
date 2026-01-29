# XaioGator Lite - Quick Start Guide

## ⚠️ IMPORTANT SAFETY WARNING ⚠️

**The E22-900M33S module WILL BE DESTROYED if TX power exceeds 9 dBm!**

This firmware is pre-configured with:
- `LORA_TX_POWER=9` (default power level)
- `SX126X_MAX_POWER=9` (hardware safety limit)

**DO NOT modify these values!**

---

## What You Need

1. **Hardware**:
   - XaioGator Lite board (with XIAO nRF52840 + E22-900M33S)
   - USB-C cable
   - LiPo battery (optional, for portable use)
   - 915MHz LoRa antenna with SMA connector

2. **Software**:
   - Visual Studio Code
   - PlatformIO extension
   - This MeshCore repository

---

## Quick Build & Flash

### Step 1: Open Project
```bash
cd ~/Desktop/MeshCore
code .
```

### Step 2: Select Your Firmware Type

**For smartphone app use (recommended):**
- Environment: `XaioGator_Lite_companion_radio_ble`
- Connects via Bluetooth to MeshCore mobile apps

**For computer/terminal use:**
- Environment: `XaioGator_Lite_companion_radio_usb`
- Connects via USB serial

**For mesh repeater:**
- Environment: `XaioGator_Lite_repeater`
- Extends network coverage

**For BBS server:**
- Environment: `XaioGator_Lite_room_server`
- Runs a shared message board

### Step 3: Build

**Option A: Build all UF2 files at once (recommended)**
```bash
cd ~/Desktop/MeshCore
./variants/xiaogator_lite/build_all_uf2.sh
```

This creates all 4 firmware variants as UF2 files in `firmware_builds/xiaogator_lite/`

**Option B: Build single firmware via PlatformIO**

In VS Code, open PlatformIO sidebar:
1. Click PlatformIO icon (alien head) on left sidebar
2. Expand "xiaogator_lite" folder
3. Click "Build" under your chosen environment

Or via command line:
```bash
pio run -e XaioGator_Lite_companion_radio_ble
```

### Step 4: Flash to Board

**Option A: Flash UF2 file (easiest)**
1. Connect XaioGator Lite via USB-C
2. **Double-tap** the reset button
3. A drive named "XIAO-SENSE" appears
4. Drag & drop the `.uf2` file from `firmware_builds/xiaogator_lite/` to the drive
5. Board automatically reboots with new firmware

**Option B: Flash via PlatformIO**
1. Connect XaioGator Lite via USB-C
2. **Double-tap** the reset button (board enters bootloader mode)
3. In PlatformIO, click "Upload" under your environment

Or via command line:
```bash
pio run -e XaioGator_Lite_companion_radio_ble -t upload
```

---

## First Time Setup

### Companion Radio (BLE)
1. Flash the `companion_radio_ble` firmware
2. Install MeshCore app on your phone:
   - **Android**: https://play.google.com/store/apps/details?id=com.liamcottle.meshcore.android
   - **iOS**: https://apps.apple.com/us/app/meshcore/id6742354151
3. Open app, scan for "XIAO nRF52840"
4. Connect (PIN: 123456 if prompted)

### Companion Radio (USB)
1. Flash the `companion_radio_usb` firmware
2. Connect via serial terminal:
   ```bash
   screen /dev/ttyACM0 115200
   # or
   pio device monitor -e XaioGator_Lite_companion_radio_usb
   ```

### Repeater
1. Flash the `repeater` firmware
2. Power on the device
3. It will automatically join the mesh and relay messages
4. Configure via serial console or remote management

### Room Server
1. Flash the `room_server` firmware
2. Users can connect and post messages
3. Acts as a BBS for the mesh network

---

## Configuration

### Change Admin Password (Repeater/Room Server)
Edit `platformio.ini` before building:
```ini
-D ADMIN_PASSWORD='"YourSecurePassword"'
```

### Change Node Location (Repeater/Room Server)
Edit `platformio.ini` before building:
```ini
-D ADVERT_LAT=40.7128
-D ADVERT_LON=-74.0060
```

### Enable Debug Logging
Uncomment in `platformio.ini`:
```ini
-D MESH_PACKET_LOGGING=1
-D MESH_DEBUG=1
```

---

## Troubleshooting

### Board Not Recognized
- **Double-tap reset button** to enter bootloader
- Check USB cable (must support data, not just charging)
- Try different USB port

### Build Errors
```bash
# Clean and rebuild
pio run -e XaioGator_Lite_companion_radio_ble -t clean
pio run -e XaioGator_Lite_companion_radio_ble
```

### Can't Connect via BLE
- Make sure BLE firmware is flashed (not USB variant)
- Check phone Bluetooth is enabled
- Reset board and try again
- PIN code is: 123456

### No LoRa Communication
- Check antenna is properly connected
- Verify other nodes are on same frequency band
- Check TX power is not set too low (default is 9)

---

## Technical Specifications

- **MCU**: Nordic nRF52840 (64MHz ARM Cortex-M4)
- **Radio**: Ebyte E22-900M33S (SX1262)
- **Frequency**: 902-928 MHz (US) / Configure as needed
- **Max TX Power**: 9 dBm (HARDWARE LIMIT)
- **Max RX Sensitivity**: -148 dBm (with LNA)
- **Flash**: 1MB + QSPI external flash
- **RAM**: 256KB
- **Bluetooth**: BLE 5.0
- **USB**: USB-C (serial + charging)

---

## Support & Resources

- **MeshCore GitHub**: https://github.com/meshcore-dev/MeshCore
- **MeshCore Discord**: https://discord.gg/BMwCtwHj5V
- **Hardware Repo**: https://github.com/wehooper4/Meshtastic-Hardware
- **Web Client**: https://app.meshcore.nz

---

## License & Legal

- **Firmware**: MIT License (MeshCore)
- **Hardware**: CC BY-NC-SA 4.0 (WeHooper4)
- **FCC Notice**: This is Part 97 Amateur Radio equipment. Requires appropriate license to operate legally in the US.
