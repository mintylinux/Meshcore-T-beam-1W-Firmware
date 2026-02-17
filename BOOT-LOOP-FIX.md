# T-Beam 1W Boot Loop Fix - MeshCore v1.12.0

## Problem
Firmware binaries flashed via the MeshCore webflasher (https://flasher.meshcore.co.uk/) were causing the T-Beam 1W to enter a continuous boot loop with repeated software resets:

```
rst:0x3 (RTC_SW_SYS_RST),boot:0x8 (SPI_FAST_FLASH_BOOT)
mode:DIO, clock div:1
```

## Root Cause
The bootloader was being compiled with incorrect flash size settings:
- **Incorrect:** 4MB flash size (from `min_spiffs.csv` partition table)
- **Correct:** 16MB flash size (actual hardware specification)

The T-Beam 1W has 16MB of flash memory, but the partition table configuration was set to `min_spiffs.csv`, which is designed for 4MB flash devices. This mismatch caused the bootloader to embed incorrect flash parameters, leading to boot failures.

## Solution
Updated `variants/lilygo_tbeam_1w_SX1262/platformio.ini` to use the correct partition table and flash settings:

### Changes Made:
```ini
board_build.partitions = default_16MB.csv
board_upload.flash_size = 16MB
board_build.flash_mode = qio
```

**Previous setting:**
```ini
board_build.partitions = min_spiffs.csv ; get around 4mb flash limit (conservative)
```

## Verification
After the fix, bootloader parameters are correct:
```
Flash size: 16MB
Flash freq: 80m
Flash mode: DIO
```

## Result
✅ Device now boots successfully without boot loops
✅ GPS initialization working (GPIO 4 ADC + correct serial pins)
✅ Battery voltage monitoring functional (7.77V reading confirmed)
✅ LoRa radio operational (noise floor -68 dBm)
✅ BLE interface starting correctly

## Updated Firmware Binaries
All three firmware variants have been rebuilt with the corrected configuration:
- `T-Beam-1W-CompanionBLE-v1.12.0.bin` (1.3M)
- `T-Beam-1W-Repeater-v1.12.0.bin` (1.2M)
- `T-Beam-1W-RoomServer-v1.12.0.bin` (1.2M)

These binaries are ready for use with the MeshCore webflasher.

## Technical Details
The merged binaries include:
- Bootloader at 0x0000 (16MB flash size configured)
- Partition table at 0x8000 (default_16MB.csv layout)
- Firmware at 0x10000

Flash mode: DIO (compatible with board)
Flash size: 16MB (matches hardware)

## Notes
- Previous battery monitoring fix (GPIO 4 ADC) is retained in these builds
- GPS serial pin swap fix (RX/TX) is included
- 7.4V Li-ion battery voltage ranges configured correctly
