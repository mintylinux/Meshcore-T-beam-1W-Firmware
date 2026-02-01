# MeshCore Web Flasher Binaries

This directory contains properly formatted firmware binaries for the **LilyGo T-Beam 1W (ESP32-S3)** that are compatible with the MeshCore Web Flasher at https://flasher.meshcore.co.uk

## Directory Structure

```
webflasher/
├── merged/              # Complete binaries ready for web flasher
│   ├── T-Beam-1W-CompanionBLE-v1.12.0.bin
│   ├── T-Beam-1W-Repeater-v1.12.0.bin
│   └── T-Beam-1W-RoomServer-v1.12.0.bin
└── README.md           # This file
```

## Firmware Types

1. **CompanionBLE** - For use with external chat apps over BLE, USB, or WiFi
2. **Repeater** - Extends network coverage by relaying messages
3. **RoomServer** - A simple BBS server for shared posts

## Technical Details

### Critical Requirements for Web Flashers

The binaries in `merged/` include **all four required components** at the correct offsets:

| Component | Offset | Description |
|-----------|--------|-------------|
| bootloader.bin | 0x0000 | ESP32-S3 bootloader |
| partitions.bin | 0x8000 | Partition table |
| **boot_app0.bin** | **0xe000** | **OTA data initial state (CRITICAL!)** |
| firmware.bin | 0x10000 | Application firmware |

### Flash Parameters

- **Flash Mode:** QIO (Quad I/O) - Required for ESP32-S3
- **Flash Frequency:** 80MHz
- **Flash Size:** 16MB (T-Beam 1W specific)
- **Chip:** ESP32-S3

### Why boot_app0.bin is Critical

The `boot_app0.bin` file at offset 0xe000 (57344) is **essential** for web flashers to work correctly. Without it:
- The device will show "invalid header: 0xffffffff" errors
- The device will fail to boot after flashing
- You'll see boot loops or crashes

This file initializes the OTA data partition, telling the bootloader which app partition to boot from.

## Creating New Binaries

### Using the Helper Script

A convenience script is provided in the project root:

```bash
cd /home/chuck/Desktop/T-Beam1watt
./create_webflasher_bins.sh
```

This script will:
1. Check that all firmware has been built
2. Create properly merged binaries for all three firmware types
3. Place them in `webflasher/merged/`

### Manual Process

If you need to create binaries manually:

```bash
# First, build the firmware
pio run -e T_Beam_1W_SX1262_companion_radio_ble
pio run -e T_Beam_1W_SX1262_repeater
pio run -e T_Beam_1W_SX1262_room_server

# Then create merged binary (example for CompanionBLE)
python3 -m esptool --chip esp32s3 merge_bin \
  -o webflasher/merged/T-Beam-1W-CompanionBLE-v1.12.0.bin \
  --flash_mode qio \
  --flash_freq 80m \
  --flash_size 4MB \
  0x0 .pio/build/T_Beam_1W_SX1262_companion_radio_ble/bootloader.bin \
  0x8000 .pio/build/T_Beam_1W_SX1262_companion_radio_ble/partitions.bin \
  0xe000 ~/.platformio/packages/framework-arduinoespressif32/tools/partitions/boot_app0.bin \
  0x10000 .pio/build/T_Beam_1W_SX1262_companion_radio_ble/firmware.bin
```

## Verification

To verify a merged binary is properly formatted:

```bash
python3 -m esptool --chip esp32s3 image_info webflasher/merged/T-Beam-1W-CompanionBLE-v1.12.0.bin
```

You should see:
- **Flash mode: QIO** (not "Invalid")
- Flash size: 4MB
- Flash freq: 80m
- No validation errors

## Troubleshooting

### Device doesn't boot after web flashing
- Ensure you're using the binaries from `webflasher/merged/`
- Verify the binary includes boot_app0.bin using the verification command above
- Check that Flash mode shows "QIO" not "Invalid"

### Web flasher fails during upload
- Hold the BOOT button while clicking INSTALL
- Try a different USB cable
- Use a different browser (Chrome or Edge recommended)
- Ensure you're not using a USB hub

### esptool works but web flasher doesn't
- This was the original problem! The solution is including boot_app0.bin
- Make sure you're using the newly created binaries with all four components

## References

- MeshCore Web Flasher: https://flasher.meshcore.co.uk
- MeshCore GitHub: https://github.com/ripplebiz/MeshCore
- ESP32-S3 Flash Troubleshooting: https://docs.espressif.com/projects/esptool/en/latest/esp32s3/troubleshooting.html

## Current Status

✅ **Binaries are CORRECT and WORKING**

The merged binaries in `merged/` have been tested and boot successfully when flashed at offset 0x0.

### Known Issue with MeshCore Webflasher

The official MeshCore webflasher (https://flasher.meshcore.co.uk) currently flashes binaries at offset **0x10000** instead of **0x0** for merged binaries. This causes the device not to boot.

**Workaround**: Use esptool to flash directly:

**Linux/Mac:**
```bash
python3 -m esptool --chip esp32s3 --port /dev/ttyACM5 --baud 460800 write_flash 0x0 webflasher/merged/T-Beam-1W-CompanionBLE-v1.12.0.bin
```

**Windows:**
- **Easy way**: Double-click `flash-windows.bat` and follow prompts
- **Manual**: See [FLASH-WINDOWS.md](FLASH-WINDOWS.md) for detailed instructions

Replace `/dev/ttyACM5` (Linux/Mac) or `COM5` (Windows) with your device's serial port.

### For MeshCore Webflasher Maintainers

A `manifest.json` file is provided in this directory that specifies the correct offset (0) for T-Beam 1W merged binaries. To add T-Beam 1W support to the official webflasher, this manifest should be integrated into the flasher configuration.

## Version History

- **v1.12.0** - Created proper merged binaries with:
  - DIO flash mode (matching PlatformIO)
  - 4MB flash size (matching PlatformIO)
  - boot_app0.bin at 0xe000 (critical for boot)
  - All components at correct offsets
  - Tested and working via esptool at offset 0x0
