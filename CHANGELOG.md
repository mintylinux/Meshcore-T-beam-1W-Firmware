# Changelog - T-Beam 1W Firmware

All notable changes to the MeshCore T-Beam 1W firmware will be documented in this file.
## [1.15.0] - 2026-05-07

### Updated
- Merged upstream MeshCore `v1.15.0` from `meshcore-dev/MeshCore`
- Rebuilt and verified all T-Beam 1W SX1262 target variants:
  - `T_Beam_1W_SX1262_companion_radio_ble`
  - `T_Beam_1W_SX1262_companion_radio_usb`
  - `T_Beam_1W_SX1262_repeater`
  - `T_Beam_1W_SX1262_room_server`
- Generated new merged firmware artifacts:
  - `T-Beam-1W-CompanionBLE-v1.15.0-merged.bin`
  - `T-Beam-1W-CompanionUSB-v1.15.0-merged.bin`
  - `T-Beam-1W-Repeater-v1.15.0-merged.bin`
  - `T-Beam-1W-RoomServer-v1.15.0-merged.bin`

### Upstream Changes (v1.14.1 → v1.15.0)
- Default Scope support
- New `GROUP_DATA` binary packet support
- Radio `rxgain` now enabled by default
- Radio frequency range extended down to 150 MHz
- New `get|set dutycycle` CLI command
- WiFi companion fixes for Heltec V4 and T-Beam 1W
- nRF companion OTA update support
- Additional sensor, board support, and stability fixes

### T-Beam 1W Specific Changes
- Added `SX126X_REGISTER_PATCH=1` for a more stable SX1262 noise floor
- Added `USE_SX1262` to the shared T-Beam 1W SX1262 build flags
- Added `T_Beam_1W_SX1262_companion_radio_usb` build target
- Switched from `min_spiffs.csv` to `default_16MB.csv` to use the full 16MB flash
- Fixed `boards/t_beam_1w.json` to use the generic Arduino `esp32s3` variant so all SX1262 targets build correctly
- Preserved and integrated T-Beam 1W fan control support in all three runtime loops:
  - Companion
  - Repeater
  - Room Server
- Updated the fan thermostat to use MCU temperature with hysteresis:
  - Fan turns ON at `45°C`
  - Fan turns OFF below `41°C`
  - Minimum runtime remains `5s`

### Technical Details (T-Beam 1W Specific)
- Flash Mode: DIO (Dual I/O)
- Flash Size: 16MB
- Flash Frequency: 80MHz
- Chip: ESP32-S3
- Board: LilyGo T-Beam 1W with SX1262 LoRa radio
## [1.14.1] - 2026-03-29

### Updated
- Merged upstream MeshCore `v1.14.1` from `meshcore-dev/MeshCore`
- Rebuilt all T-Beam 1W target variants:
  - `T-Beam-1W-CompanionBLE-v1.14.1-merged.bin`
  - `T-Beam-1W-Repeater-v1.14.1-merged.bin`
  - `T-Beam-1W-RoomServer-v1.14.1-merged.bin`

### Upstream Changes (v1.14.0 → v1.14.1)
- Repeater and Room Server: flood advert timer now uses path_hash_mode pref
- MCU temperature added to telemetry responses from room servers
- Remote LNA support
- Various bug fixes and documentation updates
- Updated webflasher references to v1.14.1

## [1.14.0] - 2026-03-07

### Added
- Updated firmware base to MeshCore `v1.14.0` (upstream merge from `meshcore-dev/MeshCore`)
- New v1.14.0 merged firmware artifacts for T-Beam 1W:
  - `T-Beam-1W-CompanionBLE-v1.14.0-merged.bin`
  - `T-Beam-1W-Repeater-v1.14.0-merged.bin`
  - `T-Beam-1W-RoomServer-v1.14.0-merged.bin`

### Changed
- Updated webflasher packaging/version references from `v1.13.0` to `v1.14.0`:
  - `create_webflasher_bins.sh`
  - `webflasher/manifest.json`
  - `webflasher/flash-windows.bat`
  - `webflasher/flash-windows.ps1`
- Rebuilt all T-Beam 1W target variants on top of MeshCore v1.14.0

### Fixed
- Resolved upstream merge conflict in `EnvironmentSensorManager.cpp` while preserving expected GPS loop behavior
- Re-generated merged binaries with required components/offsets for direct flashing:
  - bootloader @ `0x0000`
  - partitions @ `0x8000`
  - boot_app0 @ `0xE000`
  - firmware @ `0x10000`

### Technical Details (T-Beam 1W Specific)
- Flash Mode: DIO (Dual I/O)
- Flash Size: 4MB
- Flash Frequency: 80MHz
- Chip: ESP32-S3
- Board: LilyGo T-Beam 1W with SX1262 LoRa radio

---

## [1.13.0] - 2026-02-17

### Added
- **Repeater CLI Commands**: Remote management via CLI
  - `reboot` - Restart the device
  - `advert` - View advertise settings
  - `set af` - Set auto-forward mode
  - `set name` - Set device name
  - `set lat` / `set lon` - Set GPS coordinates
  - `password` - Change admin password
  - `ver` - Display firmware version
- **Room Server Enhancements**
  - Persistent preferences (loads/saves settings)
  - Same CLI commands as repeater for remote management
  - Timeout detection for push posts (evicts clients after 3 timeouts)
  - TXT_TYPE_SIGNED_PLAIN for outbound messages
- **Companion Radio Features**
  - Anonymous request support (CMD_SEND_ANON_REQ)
  - Auto-add configuration commands (CMD_SET_AUTOADD_CONFIG, CMD_GET_AUTOADD_CONFIG)
  - Allowed repeat frequency query (CMD_GET_ALLOWED_REPEAT_FREQ)
  - Granular auto-add contact type filtering
- **ESP32 Features**
  - ESP32RTCClock for repeater (keeps time across reboots)
- **Temperature-Based Fan Control** (T-Beam 1W)
  - Smart fan activation based on NTC thermistor readings (GPIO 14)
  - Fan turns ON when temperature exceeds 37°C
  - Fan turns OFF when temperature drops below 35°C (hysteresis prevents oscillation)
  - Replaces always-on fan behavior with intelligent thermal management
  - Uses Steinhart-Hart equation for accurate temperature calculation

### Fixed
- CAD (Channel Activity Detection) detection fixed
- Duplicate message IDs in repeater CLI view
- Room server crash fixes
- hasName() method missing return statement
- BaseChatMesh compilation issues for various targets
- RAK terminal chat fixes

### Changed
- Mesh packet optimization: Don't retransmit packets already handled by this node
- Refactored advertise data methods to AdvertDataHelper.cpp
- TxtDataHelpers.h with standard TXT sub-types
- Repeater debug diagnostics improvements
- Build configuration now supports ADVERT_NAME, ADVERT_LAT, ADVERT_LON defines

### Technical Details (T-Beam 1W Specific)
- Flash Mode: DIO (Dual I/O)
- Flash Size: 4MB
- Flash Frequency: 80MHz
- Chip: ESP32-S3
- Board: LilyGo T-Beam 1W with SX1262 LoRa radio

### Webflasher Binaries
All binaries include:
- Bootloader at 0x0000
- Partition table at 0x8000
- boot_app0.bin at 0xe000 (required for boot)
- Application firmware at 0x10000

**Note**: Official MeshCore webflasher currently flashes at wrong offset. Use esptool directly:
```bash
python -m esptool --chip esp32s3 --port COM5 --baud 460800 write_flash 0x0 T-Beam-1W-CompanionBLE-v1.13.0.bin
```

Or use the provided Windows scripts: `flash-windows.bat` or `flash-windows.ps1`

---

## [1.12.0] - 2026-01-31

### Added
- Initial release of T-Beam 1W webflasher binaries
- Windows flashing scripts (.bat and .ps1)
- Comprehensive documentation for Windows and Linux users
- Helper script for creating webflasher binaries

### Fixed
- Boot issue by including boot_app0.bin at correct offset
- Flash mode configuration (DIO vs QIO)
- Flash size settings for proper compatibility

### Technical Details
- Created proper merged binaries with DIO flash mode
- Fixed boot_app0.bin inclusion at 0xe000
- Verified binaries boot successfully

---

## Release Links

- **GitHub Repository**: https://github.com/mintylinux/Meshcore-T-beam-1W-Firmware
- **Upstream MeshCore**: https://github.com/meshcore-dev/MeshCore
- **MeshCore Web Flasher**: https://flasher.meshcore.co.uk
- **MeshCore Discord**: https://discord.gg/BMwCtwHj5V

## Firmware Types

| Type | Description | Use Case |
|------|-------------|----------|
| **CompanionBLE** | Mobile app interface over Bluetooth | Chat via phone/tablet apps |
| **Repeater** | Message relay node | Extends network range |
| **RoomServer** | BBS-style message board | Shared community posts |

## Installation

### Requirements
- Python 3.x with esptool installed (`pip install esptool`)
- LilyGo T-Beam 1W (ESP32-S3) device
- USB cable

### Quick Start (Windows)
1. Download the firmware
2. Double-click `flash-windows.bat`
3. Select firmware type
4. Enter COM port
5. Wait for completion

### Manual Installation (All Platforms)
```bash
# Linux/Mac
python3 -m esptool --chip esp32s3 --port /dev/ttyACM5 --baud 460800 write_flash 0x0 T-Beam-1W-CompanionBLE-v1.13.0.bin

# Windows
python -m esptool --chip esp32s3 --port COM5 --baud 460800 write_flash 0x0 T-Beam-1W-CompanionBLE-v1.13.0.bin
```

## After Flashing

### CompanionBLE
Connect via MeshCore mobile apps:
- **Web**: https://app.meshcore.nz
- **Android**: https://play.google.com/store/apps/details?id=com.liamcottle.meshcore.android
- **iOS**: https://apps.apple.com/us/app/meshcore/id6742354151

### Repeater / RoomServer
Configure via:
- **USB**: https://config.meshcore.dev
- **LoRa**: Use mobile app's Remote Management feature
