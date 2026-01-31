# Meshtastic-Inspired Improvements for T-Beam 1W

This document describes the improvements ported from Meshtastic firmware to enhance the MeshCore T-Beam 1W implementation.

## Summary of Changes

### 1. **TX Power Limiting (22 dBm Max)**
**Why:** The T-Beam 1W has a 1W PA capable of 30 dBm, but operating at maximum power causes:
- Excessive heat generation
- High current draw (1-1.5A during TX) that can brown out the system
- Regulatory compliance issues in most regions
- Reduced component lifespan

**Implementation:** Added `SX126X_MAX_POWER=22` define and enforced in `radio_set_tx_power()`:
```cpp
void radio_set_tx_power(uint8_t dbm) {
  #ifdef SX126X_MAX_POWER
  if (dbm > SX126X_MAX_POWER) {
    dbm = SX126X_MAX_POWER;  // Cap at 22 dBm
  }
  #endif
  if (dbm < -9) {
    dbm = -9;  // SX1262 minimum power
  }
  radio.setOutputPower(dbm);
}
```

**Files Modified:**
- `variants/lilygo_tbeam_1w_SX1262/platformio.ini` - Added `-D SX126X_MAX_POWER=22`
- `variants/lilygo_tbeam_1w_SX1262/target.cpp` - Added power limiting logic

---

### 2. **PA Ramp Time (800us)**
**Why:** The external 1W PA requires >800us to stabilize during power-up. The default RadioLib ramp time is 200us, which is too fast and can cause:
- Spurious emissions
- Unstable RF output
- PA damage over time

**Implementation:** Added `SX126X_PA_RAMP_TIME=0x05` (800us) in platformio.ini and applied during radio init:
```cpp
#ifdef SX126X_PA_RAMP_TIME
  // Set PA ramp time for 1W PA (needs >800us, 0x05 = 800us)
  setPaRampTime(SX126X_PA_RAMP_TIME);
#endif
```

**Files Modified:**
- `variants/lilygo_tbeam_1w_SX1262/platformio.ini` - Added `-D SX126X_PA_RAMP_TIME=0x05`
- `src/helpers/radiolib/CustomSX1262.h` - Added ramp time configuration

---

### 3. **Smart Fan Control (5 Seconds Post-TX)**
**Why:** The 1W PA generates significant heat during transmission. Continuous fan operation:
- Wastes battery power (fan draws 100-200mA)
- Creates unnecessary noise
- Reduces fan lifespan

Smart control only activates the fan when needed.

**Implementation:** 
- Fan turns ON immediately after each transmission completes
- Automatically shuts OFF after 5 seconds
- Timer-based approach prevents interference with radio operations

**Code Flow:**
1. `RadioLibWrapper::onSendFinished()` calls `radio_on_tx_complete()`
2. `radio_on_tx_complete()` turns fan ON and sets 5-second timer
3. `radio_fan_loop()` (called in main loop) checks timer and turns fan OFF

**Functions Added:**
```cpp
void radio_on_tx_complete() {
  #ifdef P_FAN_CTRL
  digitalWrite(P_FAN_CTRL, HIGH);
  fan_shutoff_time = millis() + 5000;  // 5 seconds
  #endif
}

void radio_fan_loop() {
  #ifdef P_FAN_CTRL
  if (fan_shutoff_time > 0 && millis() >= fan_shutoff_time) {
    digitalWrite(P_FAN_CTRL, LOW);
    fan_shutoff_time = 0;
  }
  #endif
}
```

**Files Modified:**
- `variants/lilygo_tbeam_1w_SX1262/target.cpp` - Added fan control functions
- `variants/lilygo_tbeam_1w_SX1262/target.h` - Exported new functions
- `src/helpers/radiolib/RadioLibWrappers.cpp` - Hook TX completion callback
- `examples/simple_repeater/main.cpp` - Call `radio_fan_loop()` in main loop
- `examples/simple_room_server/main.cpp` - Call `radio_fan_loop()` in main loop
- `examples/companion_radio/main.cpp` - Call `radio_fan_loop()` in main loop

---

## Configuration Summary

All improvements are configured in `platformio.ini`:

```ini
-D SX126X_MAX_POWER=22        # Limit TX power to 22 dBm
-D SX126X_PA_RAMP_TIME=0x05   # 800us PA ramp time
-D P_FAN_CTRL=41              # Fan control GPIO (already defined)
```

---

## Benefits

### Power Consumption
- **Fan control**: Saves ~100-200mA continuous draw, only activating for brief periods after TX
- **22 dBm limit**: Reduces peak TX current from ~1.5A to ~800mA

### Thermal Management
- PA operates within safe temperature range
- Fan cooling applied when needed, preventing thermal shutdown
- Extended component lifespan

### RF Performance
- Proper PA ramp time ensures clean spectral emissions
- Stable RF output without spurious signals
- Regulatory compliance

### System Stability
- Prevents brown-outs during high-power TX
- Reduces load on PMU and battery
- More reliable operation on lower battery voltages

---

## Testing Recommendations

1. **TX Power Verification:**
   ```
   # Monitor serial output during transmission
   # Should never exceed 22 dBm
   ```

2. **Fan Operation:**
   - Send a mesh packet
   - Fan should turn ON immediately after TX completes
   - Fan should turn OFF exactly 5 seconds later
   - Verify with multimeter: GPIO 41 should go HIGH then LOW

3. **Thermal Testing:**
   - Run continuous TX for 1 minute (send packets every few seconds)
   - PA should remain warm but not hot to touch
   - Fan should cycle ON/OFF with each transmission

4. **Current Draw:**
   - Idle (RX): ~120-150mA
   - TX (22 dBm): ~800-900mA
   - TX (22 dBm) + Fan: ~1000-1100mA

---

## Comparison: MeshCore vs Meshtastic

| Feature | Meshtastic | MeshCore (Before) | MeshCore (After) |
|---------|------------|-------------------|------------------|
| TX Power Limit | 22 dBm enforced | 22 dBm (config only) | 22 dBm enforced |
| PA Ramp Time | 800us configured | 200us (default) | 800us configured |
| Fan Control | Basic (always ON) | OFF by default | Smart (5s post-TX) |
| Power Savings | Moderate | Good | Excellent |

---

## Future Improvements

1. **Temperature-based fan control**: Monitor PA temperature and adjust fan duration
2. **Adaptive TX power**: Reduce power when link quality is good
3. **Duty cycle limiting**: Prevent continuous TX to avoid overheating
4. **Fan PWM control**: Variable speed based on thermal conditions

---

## Credits

These improvements are based on analysis of the Meshtastic firmware (https://github.com/meshtastic/firmware), specifically:
- `src/mesh/SX126xInterface.cpp` - TX power and PA configuration
- `variants/esp32s3/t-beam-1w/variant.h` - Hardware definitions

Smart fan control implementation is an enhancement over Meshtastic's basic approach.
