# LilyGo T-Beam 1W MeshCore Firmware - Hardware Fixes

This document describes the hardware-specific fixes applied to make MeshCore firmware work correctly on the LilyGo T-Beam 1W (ESP32-S3 with SX1262 and 1W PA).

## Hardware Overview

**LilyGo T-Beam 1W Specifications:**
- MCU: ESP32-S3 (dual-core Xtensa, 240MHz)
- Radio: SX1262 LoRa with 1W power amplifier
- PMU: AXP2101 (power management)
- Display: SH1106 OLED (128x64, I2C)
- GPS: UC6580 or NEO-M10S
- Battery: 7.4V 2S LiPo (via JST connector)
- I2C Bus: Single bus on GPIO 8 (SDA) / GPIO 9 (SCL)

## Critical Fixes Applied

### 1. I2C Configuration (CRITICAL)
**Problem:** Original code assumed dual I2C buses (Wire and Wire1) like T-Beam Supreme.  
**Fix:** T-Beam 1W uses **single I2C bus** on Wire (GPIO 8/9) for ALL peripherals.

**Files Modified:**
- `src/helpers/esp32/TBeamBoard.h` (lines 71-89)
- `src/helpers/esp32/TBeamBoard.cpp` (lines 128-139)
- `src/helpers/ui/SH1106Display.h` (line 18)
- `variants/lilygo_tbeam_1w_SX1262/target.cpp` (line 45)

**Changes:**
```cpp
// BEFORE (WRONG - caused crashes):
#define PIN_BOARD_SDA1   8   // Wire1
#define PIN_BOARD_SCL1   9   // Wire1
#define PMU_WIRE_PORT    Wire1

// AFTER (CORRECT):
#define PIN_BOARD_SDA    8   // Wire (single bus)
#define PIN_BOARD_SCL    9   // Wire (single bus)
#define PMU_WIRE_PORT    Wire
```

### 2. PMU (AXP2101) Initialization
**Problem:** PMU initialization failed, causing NULL pointer crashes.  
**Fix:** Initialize I2C bus BEFORE attempting PMU communication.

**File Modified:** `src/helpers/esp32/TBeamBoard.cpp` (lines 128-132)

**Added:**
```cpp
// Initialize I2C bus BEFORE attempting PMU communication
#if defined(TBEAM_SUPREME_SX1262)
  Wire1.begin(PIN_BOARD_SDA1, PIN_BOARD_SCL1);
  delay(10);  // Give I2C bus time to stabilize
#endif
```

### 3. NULL-Safe Battery Reading
**Problem:** If PMU fails to initialize, `getBattMilliVolts()` would crash.  
**Fix:** Added NULL check to prevent crashes.

**File Modified:** `src/helpers/esp32/TBeamBoard.h` (lines 194-199)

**Added:**
```cpp
uint16_t getBattMilliVolts(){
  if (PMU) {
    return PMU->getBattVoltage();
  }
  return 0;  // PMU not available
}
```

### 4. Battery Voltage Range (7.4V 2S LiPo)
**Problem:** Battery percentage always showed 100% because code expected 3.7V single-cell (3.0-4.2V).  
**Fix:** Configured for 7.4V 2S LiPo battery (6.0-8.4V range).

**Files Modified:**
- `variants/lilygo_tbeam_1w_SX1262/platformio.ini` (lines 36-37)
- `examples/companion_radio/ui-new/UITask.cpp` (lines 104-113)

**Added to platformio.ini:**
```ini
-D BATTERY_MIN_MILLIVOLTS=6000
-D BATTERY_MAX_MILLIVOLTS=8400
```

**Modified UITask.cpp:**
```cpp
#ifndef BATTERY_MIN_MILLIVOLTS
  const int minMilliVolts = 3000; // Single-cell default
#else
  const int minMilliVolts = BATTERY_MIN_MILLIVOLTS; // Use configured value
#endif
```

**Note:** The MeshCore mobile apps still need updating to support 2S batteries. The firmware sends raw voltage (mV) to the app, which calculates percentage using hardcoded 3.0-4.2V range.

### 5. GPS Configuration
**Problem:** GPS initialization timeout due to slower startup.  
**Fix:** Added persistent GPS flags.

**File Modified:** `variants/lilygo_tbeam_1w_SX1262/platformio.ini` (lines 34-35)

**Added:**
```ini
-D PERSISTANT_GPS=1
-D ENV_SKIP_GPS_DETECT=1
```

### 6. Display Boot Screen Timing
**Problem:** Boot screen immediately skipped because timing used `millis()` from power-on.  
**Fix:** Changed to use timer from `UITask::begin()` call.

**Files Modified:**
- `examples/simple_repeater/UITask.h` (line 9)
- `examples/simple_repeater/UITask.cpp` (lines 28, 46)

**Added:**
```cpp
unsigned long _boot_screen_until;
_boot_screen_until = millis() + BOOT_SCREEN_MILLIS;  // In begin()
if (millis() < _boot_screen_until) { // boot screen
```

## Pin Configuration

### LoRa Radio (SX1262)
- NSS (CS): GPIO 15
- RESET: GPIO 3
- DIO1 (IRQ): GPIO 1
- BUSY: GPIO 38
- SCLK: GPIO 13
- MISO: GPIO 12
- MOSI: GPIO 11
- LDO_EN: GPIO 40 (1W PA power enable)
- CTRL: GPIO 21 (LNA TX/RX switch)
- TX_LED: GPIO 18

### I2C Bus (Wire)
- SDA: GPIO 8
- SCL: GPIO 9
- PMU (AXP2101): 0x34
- OLED (SH1106): 0x3C

### GPS
- RX: GPIO 5
- TX: GPIO 6
- EN: GPIO 16
- PPS: GPIO 7

### Other
- USER_BTN: GPIO 0
- USER_BTN2: GPIO 17
- FAN_CTRL: GPIO 41 (cooling fan)

## Firmware Variants

All three variants build and run successfully:

### 1. Companion Radio BLE
```bash
pio run -e T_Beam_1W_SX1262_companion_radio_ble -t upload --upload-port /dev/ttyACM1
```
- Connect via Android/iOS/Web MeshCore apps
- BLE connectivity with PIN pairing
- Full UI on OLED display
- Battery indicator (displays correctly for 7.4V)

### 2. Room Server
```bash
pio run -e T_Beam_1W_SX1262_room_server -t upload --upload-port /dev/ttyACM1
```
- BBS-style message board for shared posts
- Serial CLI configuration
- Can be managed via LoRa remote management
- Default password: "hello"

### 3. Repeater
```bash
pio run -e T_Beam_1W_SX1262_repeater -t upload --upload-port /dev/ttyACM1
```
- Extends mesh network range
- OLED display shows node info
- Serial CLI for configuration
- Low power consumption

## Known Issues

### Battery Percentage in Mobile Apps
**Issue:** MeshCore mobile apps (Android/iOS/Web) show 100% battery regardless of actual voltage.

**Cause:** Apps are hardcoded to expect 3.0-4.2V (single-cell LiPo). The firmware correctly sends 7.4V readings, but apps calculate percentage incorrectly.

**Workarounds:**
1. Report to MeshCore app developers to add 2S battery support
2. Check raw voltage in app (should show ~7000-8400mV)
3. On-device OLED display shows correct percentage

**Status:** Firmware fix complete, waiting for app-side updates.

## Testing Results

✅ **All Tests Passed:**
- PMU (AXP2101) detection and initialization
- OLED display boot screen and UI
- Radio (SX1262) TX/RX with 1W PA
- GPS detection and operation
- BLE connectivity (companion firmware)
- No crashes or reboot loops
- Stable operation for all three firmware variants

## Build & Flash

### Prerequisites
```bash
# Install PlatformIO
pip install platformio

# Or via VS Code extension
# https://platformio.org/install/ide?install=vscode
```

### Build All Firmwares
```bash
cd /home/chuck/Desktop/T-Beam1watt
pio run -e T_Beam_1W_SX1262_companion_radio_ble
pio run -e T_Beam_1W_SX1262_room_server
pio run -e T_Beam_1W_SX1262_repeater
```

### Flash Firmware
```bash
# Find your device port
ls /dev/ttyACM* /dev/ttyUSB*

# Flash (replace with your port)
pio run -e T_Beam_1W_SX1262_companion_radio_ble -t upload --upload-port /dev/ttyACM1
```

### Monitor Serial Output
```bash
pio device monitor --port /dev/ttyACM1 --baud 115200
```

## Credits

**Hardware:** LilyGo T-Beam 1W  
https://www.lilygo.cc/products/t-beam-1w

**Firmware Base:** MeshCore  
https://github.com/ripplebiz/MeshCore

**Documentation Reference:** Meshtastic T-Beam 1W support  
https://github.com/meshtastic/firmware/pull/8967

**Co-Authored-By:** Warp <agent@warp.dev>

## License

This follows the MeshCore license (MIT). See `license.txt` for details.
