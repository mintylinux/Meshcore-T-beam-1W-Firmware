# XaioGator Lite Repeater - Configuration Guide

Your repeater is now running! Here's how to configure it.

## Current Configuration

Based on the firmware settings in `platformio.ini`:

```ini
-D ADVERT_NAME='"XaioGator_Lite Repeater"'
-D ADVERT_LAT=0.0
-D ADVERT_LON=0.0
-D ADMIN_PASSWORD='"password"'
-D MAX_NEIGHBOURS=50
```

**LoRa Settings (from base config):**
- Frequency: 869.525 MHz (default, EU band)
- Bandwidth: 250 kHz
- Spreading Factor: 11
- TX Power: 9 dBm (MAX - hardware limited)

## Configuration Options

### Option 1: Via MeshCore Web Config Tool (Recommended)

1. **Go to**: https://config.meshcore.dev
2. **Connect via USB**:
   - Your device should appear as "XIAO nRF52840"
   - Click "Connect" and select the serial port
3. **Configure**:
   - Device name
   - Location (GPS coordinates)
   - Admin password
   - LoRa region/frequency

### Option 2: Via MeshCore Mobile App (Remote Management)

1. **Install MeshCore app** on your phone (Android/iOS)
2. **Flash companion radio firmware** on another XIAO device
3. **Connect** companion to your phone via BLE
4. **Use Remote Management** feature to configure the repeater over LoRa

### Option 3: Rebuild with Custom Settings

Edit the configuration before building:

**1. Edit platformio.ini:**
```bash
nano ~/Desktop/MeshCore/variants/xiaogator_lite/platformio.ini
```

**2. Find the repeater section and modify:**

```ini
[env:XaioGator_Lite_repeater]
extends = XaioGator_Lite
build_flags =
  ${XaioGator_Lite.build_flags}
  -D ADVERT_NAME='"MyRepeater"'          # Change device name
  -D ADVERT_LAT=40.7128                   # Your latitude
  -D ADVERT_LON=-74.0060                  # Your longitude
  -D ADMIN_PASSWORD='"MySecurePassword"'  # Change password!
  -D MAX_NEIGHBOURS=50
```

**3. For US 915MHz region, also change in [XaioGator_Lite] section:**

```ini
[XaioGator_Lite]
# ... existing settings ...
build_flags = ${nrf52_base.build_flags}
  # ... other flags ...
  -D LORA_FREQ=915.0      # Change from 869.525 to 915.0 for US
  -D LORA_BW=250
  -D LORA_SF=11
```

**4. Rebuild and reflash:**
```bash
cd ~/Desktop/MeshCore
platformio run -e XaioGator_Lite_repeater -t upload
```

## LoRa Frequency Regions

**Choose your region:**

| Region | Frequency | Bandwidth | Note |
|--------|-----------|-----------|------|
| **US** | 915.0 MHz | 250 kHz | North America |
| **EU** | 869.525 MHz | 250 kHz | Europe (default) |
| **AU** | 915.0 MHz | 250 kHz | Australia |
| **AS** | 923.0 MHz | 250 kHz | Asia |

⚠️ **Always use frequencies legal in your region!**

## Current Device Status

Your repeater is running with:
- **Port**: /dev/ttyACM0
- **Status**: Active and ready
- **Mode**: Repeater (auto-relays mesh messages)
- **Default Password**: "password" ⚠️ **CHANGE THIS!**

## Testing the Repeater

### 1. Check USB Connection
```bash
platformio device list | grep XIAO
```

### 2. Monitor Activity (if serial output is enabled)
```bash
screen /dev/ttyACM0 115200
# Press Ctrl+A then K then Y to exit
```

### 3. Test with Another MeshCore Device
- Set up a companion radio on another device
- Send a message
- Repeater should relay it (check range extends)

## Important Settings to Change

### Priority 1: Admin Password
**Default**: "password"
**Risk**: Anyone can admin your repeater!
**Fix**: Rebuild with custom password (see Option 3 above)

### Priority 2: Location
**Default**: 0.0, 0.0 (off the coast of Africa!)
**Why**: Helps users see repeater location on map
**Fix**: Set your actual GPS coordinates

### Priority 3: Frequency/Region
**Default**: 869.525 MHz (EU)
**Why**: Must match your local regulations
**Fix**: Change LORA_FREQ for your region

## Troubleshooting

### Repeater not responding?
- Check USB connection: `lsusb | grep 2886`
- Check serial port: `ls -la /dev/ttyACM*`
- Verify firmware flashed: Look for LED activity

### Can't configure via web tool?
- Try different browser (Chrome/Edge work best)
- Check USB permissions: `groups | grep dialout`
- If not in dialout group: `sudo usermod -a -G dialout chuck`

### Need to reflash?
```bash
cd ~/Desktop/MeshCore
platformio run -e XaioGator_Lite_repeater -t upload
```

## Next Steps

1. ⚠️ **Change the admin password** (rebuild with custom password)
2. 📍 **Set your location** (lat/lon coordinates)
3. 📡 **Configure for your region** (US: 915 MHz, EU: 869 MHz, etc.)
4. 🔋 **Test it!** Set up another device and verify relay works
5. 🌍 **Deploy it** somewhere to extend your mesh coverage

## Additional Resources

- **MeshCore Config Tool**: https://config.meshcore.dev
- **MeshCore Discord**: https://discord.gg/BMwCtwHj5V
- **Documentation**: ~/Desktop/MeshCore/variants/xiaogator_lite/
- **Hardware Design**: https://github.com/wehooper4/Meshtastic-Hardware

---

**Your repeater is working!** It's currently using EU frequency (869.525 MHz) and default settings. Follow the steps above to customize it for your needs.
