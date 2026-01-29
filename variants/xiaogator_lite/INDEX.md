# XaioGator Lite - MeshCore Firmware Documentation

## 📋 Table of Contents

1. **[INSTALL.md](INSTALL.md)** - Start here! Install PlatformIO and build firmware
2. **[QUICKSTART.md](QUICKSTART.md)** - Quick guide to building and flashing
3. **[README.md](README.md)** - Complete technical documentation
4. **[build_all_uf2.sh](build_all_uf2.sh)** - Automated build script for all firmware

---

## 🚀 Getting Started (Quick Path)

### 1️⃣ Install PlatformIO
```bash
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/scripts/get-platformio.py -o get-platformio.py
python3 get-platformio.py
export PATH=$PATH:~/.platformio/penv/bin
```

### 2️⃣ Build All Firmware
```bash
cd ~/Desktop/MeshCore
./variants/xiaogator_lite/build_all_uf2.sh
```

Wait 10-20 minutes for first build (downloads dependencies)

### 3️⃣ Flash to Board
1. Connect XaioGator Lite via USB-C
2. Double-tap reset button
3. Drag `.uf2` file from `firmware_builds/xiaogator_lite/` to XIAO-SENSE drive
4. Done!

---

## ⚠️ CRITICAL SAFETY WARNING

**The E22-900M33S module WILL BE DESTROYED if TX power exceeds 9 dBm!**

This firmware is pre-configured with safety limits:
- `LORA_TX_POWER=9` 
- `SX126X_MAX_POWER=9`

**DO NOT modify these settings!**

---

## 📦 Available Firmware Types

### 1. Companion Radio (BLE) - **Recommended**
- **File**: `XaioGator_Lite_companion_radio_ble.uf2`
- **Use**: Connect to smartphone via Bluetooth
- **Apps**: Android, iOS, Web
- **Features**: BLE connectivity, 350 contacts, 40 channels

### 2. Companion Radio (USB)
- **File**: `XaioGator_Lite_companion_radio_usb.uf2`
- **Use**: Connect to computer via USB serial
- **Apps**: Terminal, Python CLI
- **Features**: USB serial interface, same capacity as BLE

### 3. Repeater
- **File**: `XaioGator_Lite_repeater.uf2`
- **Use**: Extend mesh network range
- **Features**: Automatic message relay, 50 neighbors
- **Config**: Serial console or remote management

### 4. Room Server
- **File**: `XaioGator_Lite_room_server.uf2`
- **Use**: BBS-style message board
- **Features**: Shared posts, multi-user access
- **Config**: Serial console or remote management

---

## 🔧 Hardware Specifications

| Component | Details |
|-----------|---------|
| **MCU** | Seeed XIAO nRF52840 (Nordic nRF52840) |
| **CPU** | 64MHz ARM Cortex-M4 |
| **RAM** | 256KB |
| **Flash** | 1MB + QSPI external |
| **Radio** | Ebyte E22-900M33S (SX1262) |
| **Frequency** | 902-928 MHz |
| **TX Power** | Max 9 dBm (hardware limit) |
| **RX Sensitivity** | -148 dBm (with LNA) |
| **Bluetooth** | BLE 5.0 |
| **USB** | USB-C (serial + charging) |

---

## 📱 Client Applications

After flashing firmware, connect with:

- **Web**: https://app.meshcore.nz
- **Android**: [Google Play Store](https://play.google.com/store/apps/details?id=com.liamcottle.meshcore.android)
- **iOS**: [App Store](https://apps.apple.com/us/app/meshcore/id6742354151)
- **Python CLI**: https://github.com/fdlamotte/meshcore-cli
- **Node.js**: https://github.com/liamcottle/meshcore.js

---

## 🗺️ Pin Mapping Reference

| XIAO Pin | Function | E22 Pin | Notes |
|----------|----------|---------|-------|
| D1 | IRQ | DIO1 | LoRa interrupt |
| D2 | RESET | NRST | Radio reset |
| D3 | BUSY | BUSY | Radio busy signal |
| D4 | NSS | NSS | SPI chip select |
| D5 | RXEN | RXEN | RX enable |
| D6 | SCL | - | I2C sensors |
| D7 | SDA | - | I2C sensors |
| D8 | SCK | SCK | SPI clock |
| D9 | MISO | MISO | SPI MISO |
| D10 | MOSI | MOSI | SPI MOSI |
| D11 | LED | - | TX indicator |

---

## 🛠️ Customization

### Change TX Power (Advanced Users Only)
⚠️ **DO NOT exceed 9 dBm!**

Edit `platformio.ini`:
```ini
-D LORA_TX_POWER=9    # Never exceed 9!
-D SX126X_MAX_POWER=9  # Hardware safety limit
```

### Change Admin Password
Edit `platformio.ini` before building:
```ini
-D ADMIN_PASSWORD='"YourPassword"'
```

### Change Location (Repeater/Room Server)
Edit `platformio.ini`:
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

## 🐛 Troubleshooting Quick Reference

| Problem | Solution |
|---------|----------|
| `pio: command not found` | Add to PATH: `export PATH=$PATH:~/.platformio/penv/bin` |
| Build fails | Clean: `pio run -e XaioGator_Lite_companion_radio_ble -t clean` |
| Board not recognized | Double-tap reset button |
| XIAO-SENSE drive doesn't appear | Try different USB port/cable |
| Can't connect via BLE | Check BLE firmware is flashed, not USB variant |
| No LoRa communication | Check antenna connection, verify TX power |

---

## 📚 Documentation Files

- **[INSTALL.md](INSTALL.md)** - Complete installation instructions with PlatformIO setup
- **[QUICKSTART.md](QUICKSTART.md)** - Fast-track guide for experienced users
- **[README.md](README.md)** - Full technical documentation with pin mappings
- **[build_all_uf2.sh](build_all_uf2.sh)** - Automated build script

---

## 🔗 Links & Resources

### MeshCore
- **GitHub**: https://github.com/meshcore-dev/MeshCore
- **Discord**: https://discord.gg/BMwCtwHj5V
- **Flasher**: https://flasher.meshcore.co.uk
- **Web Config**: https://config.meshcore.dev

### Hardware
- **XaioGator Design**: https://github.com/wehooper4/Meshtastic-Hardware/tree/main/XaioSeries/XaioGator/Lite
- **XIAO nRF52840**: https://wiki.seeedstudio.com/XIAO_BLE
- **E22 Module**: Ebyte E22-900M33S datasheet

### Support
- **PlatformIO Docs**: https://docs.platformio.org
- **Nordic nRF52 SDK**: https://infocenter.nordicsemi.com

---

## ⚖️ Legal & Licensing

### Hardware
- **Designer**: WeHooper4
- **License**: CC BY-NC-SA 4.0
- **Commercial Use**: Not permitted without permission

### Firmware
- **Project**: MeshCore
- **License**: MIT License
- **Commercial Use**: Permitted

### Regulatory Notice
This is **Amateur Radio equipment** under FCC Part 97:
- ❌ Not certified for unlicensed operation
- ✅ Requires amateur radio license in USA
- ⚠️ Users must comply with local regulations

---

## 🙏 Credits

- **Hardware Design**: WeHooper4
- **MeshCore Firmware**: MeshCore development team
- **MCU Platform**: Seeed Studio (XIAO nRF52840)
- **Radio Module**: Ebyte (E22-900M33S)

---

## 📝 Version Info

- **Firmware Base**: MeshCore (latest from main branch)
- **Configuration Version**: 1.0
- **Last Updated**: 2026-01-04
- **TX Power Limit**: 9 dBm (hardware safety)

---

**Need Help?** Join the [MeshCore Discord](https://discord.gg/BMwCtwHj5V) for community support!
