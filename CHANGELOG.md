# Changelog — T-Beam 1W SX1262 Firmware

## v1.17.1 - 2026-08-28

Based on MeshCore v1.17.1 (upstream main)

### Changes
- **Rebased onto MeshCore v1.17.1** — all upstream improvements since v1.15.0
- **PA ramp time fix (#3)**: Increased from 0x05 (800µs) to 0x06 (1700µs) per LilyGo recommendation for >800µs PA stabilization
- **Temperature-based fan control**: Fan now activates based on MCU temperature instead of every transmission
  - Fan ON at ≥45°C
  - Fan OFF below 41°C (hysteresis)
  - Minimum 5 second runtime
  - Active in all builds (Repeater, Room Server, Companion USB/BLE)
- **SX126X_REGISTER_PATCH=1** for more stable SX1262 noise floor
- **USE_SX1262** build flag added
- **default_16MB.csv** partitions — uses full 16MB flash
- **Board JSON** uses generic esp32s3 variant for reliable builds

## v1.15.0 - 2026-04-18

Based on MeshCore v1.15.0 (upstream dev)

### Changes
- Initial release with temperature-based fan thermostat (ON at 45°C, OFF below 41°C, 5s min runtime)
- Added SX126X_REGISTER_PATCH=1 for stable SX1262 noise floor
- Added USE_SX1262 build flag
- Added T_Beam_1W_SX1262_companion_radio_usb build target
- Switched from min_spiffs.csv to default_16MB.csv for full 16MB flash
- Fixed boards/t_beam_1w.json to use generic Arduino esp32s3 variant
- Fan control integrated in all three runtime loops (Repeater, Companion, Room Server)
- ADC-based battery voltage reading for 2S 18650 configuration

## v1.14.1 - 2026-04-10

Based on MeshCore dev branch

### Changes
- Initial T-Beam 1W SX1262 board support
- Custom SX1262 wrapper with 1W PA control (LDO enable, LNA switching, TX LED)
- SH1106 OLED display support
- GPS with persistent mode and 9600 baud
- Cooling fan control on GPIO 41
- Dual 18650 battery monitoring (6.0V-8.4V range)
- Build targets: Repeater, Room Server, Companion BLE, ESPNow Bridge
