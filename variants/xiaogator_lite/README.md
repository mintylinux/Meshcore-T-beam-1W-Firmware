# XaioGator Lite - MeshCore Firmware

Custom MeshCore firmware configuration for the **XaioGator Lite** board designed by **WeHooper4**.

## Hardware Overview

The XaioGator Lite is a client-focused LoRa mesh node featuring:
- **MCU**: Seeed XIAO nRF52840 (Sense)
- **Radio**: Ebyte E22-900M33S (SX1262-based, 1W output with LNA)
- **Power**: Boost converter for 5V radio power, linear charger for battery
- **Design**: 2-layer PCB, DIY assembly possible

This is a reduced-cost version without GPS, focused on portable/mobile client use.

## Pin Configuration

Based on the XaioGator Lite schematic:

| XIAO Pin | Function | E22 Module Pin | Description |
|----------|----------|----------------|-------------|
| D0       | GPIO     | (GPS_EN)       | GPS Enable (not used on Lite) |
| D1       | IRQ      | DIO1           | LoRa interrupt |
| D2       | RESET    | NRST           | Radio reset |
| D3       | BUSY     | BUSY           | Radio busy signal |
| D4       | NSS      | NSS            | SPI chip select |
| D5       | RXEN     | RXEN           | RX enable for RF switch |
| D6       | SCL      | -              | I2C clock (sensors) |
| D7       | SDA      | -              | I2C data (sensors) |
| D8       | SCK      | SCK            | SPI clock |
| D9       | MISO     | MISO           | SPI MISO |
| D10      | MOSI     | MOSI           | SPI MOSI |
| D11      | LED      | -              | TX LED (built-in) |

## Radio Configuration

- **Module**: E22-900M33S (SX1262 with 33dBm PA)
- **TX Power**: 9 dBm (MAX - DO NOT EXCEED!)
- **Max Power Limit**: 9 (hardware protection enabled)
- **TCXO**: 1.8V (DIO3 controlled)
- **RF Switch**: DIO2 controlled (automatic)
- **Current Limit**: 140mA
- **RX Gain**: Boosted mode enabled

### ⚠️ CRITICAL WARNING ⚠️

**DO NOT SET TX POWER HIGHER THAN 9!**

The E22-900M33S module will be **permanently damaged** if TX power is set above 9 dBm in MeshCore. The firmware has been configured with `SX126X_MAX_POWER=9` to protect the hardware, but do not attempt to override this setting.

## Available Firmware Builds

The following PlatformIO environments are available:

### 1. Companion Radio (BLE)
**Environment**: `XaioGator_Lite_companion_radio_ble`

Connects to smartphone apps via Bluetooth LE.
- BLE PIN: 123456
- Max contacts: 350
- Max channels: 40
- QSPI Flash support enabled

### 2. Companion Radio (USB)
**Environment**: `XaioGator_Lite_companion_radio_usb`

Connects via USB serial for terminal/computer interface.
- USB serial communication
- Max contacts: 350
- Max channels: 40

### 3. Repeater
**Environment**: `XaioGator_Lite_repeater`

Simple mesh repeater node.
- Advertises as "XaioGator_Lite Repeater"
- Admin password: "password" (change this!)
- Max neighbors: 50

### 4. Room Server
**Environment**: `XaioGator_Lite_room_server`

BBS-style room server for shared posts.
- Advertises as "XaioGator_Lite Room"
- Admin password: "password" (change this!)

## Building and Flashing

### Prerequisites
1. Install [PlatformIO](https://platformio.org/install)
2. Install Visual Studio Code (recommended)
3. Install PlatformIO extension in VS Code

### Build Instructions

```bash
# Navigate to MeshCore directory
cd /home/chuck/Desktop/MeshCore

# Build companion radio (BLE)
pio run -e XaioGator_Lite_companion_radio_ble

# Build companion radio (USB)
pio run -e XaioGator_Lite_companion_radio_usb

# Build repeater
pio run -e XaioGator_Lite_repeater

# Build room server
pio run -e XaioGator_Lite_room_server
```

### Flashing

1. Connect XaioGator Lite via USB
2. Double-tap the reset button to enter bootloader mode
3. Flash using PlatformIO:

```bash
# Flash the firmware
pio run -e XaioGator_Lite_companion_radio_ble -t upload
```

Or use the PlatformIO interface in VS Code.

## Hardware Design

Design files available at:
https://github.com/wehooper4/Meshtastic-Hardware/tree/main/XaioSeries/XaioGator/Lite

## Legal Notice

This is **Amateur Radio equipment** under FCC Part 97.
- Not certified for unlicensed operation
- Users must comply with all applicable regulations
- US operation requires FCC Part 97 compliance

## Credits

- **Hardware Designer**: WeHooper4
- **MeshCore Firmware**: MeshCore development team
- **Board**: Seeed Studio XIAO nRF52840
- **Radio Module**: Ebyte E22-900M33S

## License

Hardware design by WeHooper4 is licensed under CC BY-NC-SA 4.0.
MeshCore firmware is licensed under MIT License.
