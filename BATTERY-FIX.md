# Battery Percentage Fix for T-Beam 1W

## Problem
The T-Beam 1W uses a 2S (2-cell series) LiPo battery pack with voltage range 6.0V-8.4V, but the MeshCore mobile app expects single-cell voltage (3.0V-4.2V) for battery percentage calculation. This caused a mismatch where:

- **Device OLED**: Shows correct battery percentage (e.g., 50-75%) based on 2S voltage (6.0V-8.4V range)
- **Mobile App**: Shows incorrect 100% because it receives per-cell voltage (~3.7V) and interprets it as a fully charged single cell

## Root Cause
The firmware was sending per-cell voltage to the app by dividing the total battery voltage by 2:
```cpp
app_battery_mv = (battery_millivolts + (BATTERY_SERIES_CELLS/2)) / BATTERY_SERIES_CELLS;
```

While this gave the correct per-cell voltage, the app doesn't know about the 2S battery configuration and uses single-cell thresholds (3.0V-4.2V) to calculate percentage. A healthy 2S battery at 7.4V (3.7V per cell) appears as 58% when calculated with single-cell thresholds, but the device shows the correct percentage based on the full 6.0V-8.4V range.

## Solution
Instead of sending raw voltage and hoping the app calculates correctly, we now:

1. **Calculate battery percentage on the device** using board-specific voltage ranges:
   - Minimum: `BATTERY_MIN_MILLIVOLTS` (6000mV for 2S)
   - Maximum: `BATTERY_MAX_MILLIVOLTS` (8400mV for 2S)

2. **Convert percentage to "fake" millivolts** that the app will interpret correctly:
   - Map 0-100% to the single-cell range (3000-4200mV)
   - Example: 50% battery → 3600mV sent to app → app calculates 50%

This ensures the app shows the same battery percentage as the device OLED display.

## Implementation
Modified two locations in `examples/companion_radio/MyMesh.cpp`:

1. **`CMD_GET_BATT_AND_STORAGE` handler** (line ~1210): Used when app queries battery status
2. **`CMD_GET_STATS` handler for `STATS_TYPE_CORE`** (line ~1559): Used for periodic stats updates

Both now use this logic:
```cpp
// Calculate battery percentage using board-specific voltage ranges
#ifndef BATTERY_MIN_MILLIVOLTS
    const int minMilliVolts = 3000; // Default: single-cell LiPo minimum
#else
    const int minMilliVolts = BATTERY_MIN_MILLIVOLTS;
#endif
#ifndef BATTERY_MAX_MILLIVOLTS
    const int maxMilliVolts = 4200; // Default: single-cell LiPo maximum
#else
    const int maxMilliVolts = BATTERY_MAX_MILLIVOLTS;
#endif

int batteryPercentage = ((battery_millivolts - minMilliVolts) * 100) / (maxMilliVolts - minMilliVolts);
if (batteryPercentage < 0) batteryPercentage = 0;
if (batteryPercentage > 100) batteryPercentage = 100;

// Convert percentage to "fake" millivolts that app will interpret correctly
// Map 0-100% to 3000-4200mV range so app's single-cell calculation shows correct %
uint16_t app_battery_mv = 3000 + ((batteryPercentage * (4200 - 3000)) / 100);
```

## Configuration
The battery voltage thresholds are defined in `variants/lilygo_tbeam_1w_SX1262/platformio.ini`:
```ini
-D BATTERY_MIN_MILLIVOLTS=6000   # 2S minimum (3.0V × 2)
-D BATTERY_MAX_MILLIVOLTS=8400   # 2S maximum (4.2V × 2)
-D BATTERY_SERIES_CELLS=2        # Number of cells in series
```

## Testing
After flashing the updated firmware:
1. Check device OLED for battery percentage
2. Check MeshCore app for battery percentage
3. Both should now show the same value (within ±5% due to rounding)

## Compatibility
- Works with both PMU-based and ADC-based battery monitoring
- Falls back to default single-cell ranges if `BATTERY_MIN_MILLIVOLTS` and `BATTERY_MAX_MILLIVOLTS` are not defined
- No changes required to the MeshCore mobile app

## Files Modified
- `examples/companion_radio/MyMesh.cpp` - Added battery percentage calculation and voltage remapping
