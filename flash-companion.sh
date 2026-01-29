#!/bin/bash
# Flash T-Beam 1W Companion Radio firmware with bootloader and partitions

echo "================================================"
echo "T-Beam 1W - Companion Radio Flash Script"
echo "================================================"
echo ""
echo "IMPORTANT: Put device in download mode:"
echo "  1. Hold BOOT button (GPIO 0)"
echo "  2. Press and release RESET button"
echo "  3. Release BOOT button"
echo ""
echo "Press Enter when ready..."
read

# Auto-detect the port
PORT=""
if [ -e /dev/ttyACM0 ]; then
    PORT="/dev/ttyACM0"
elif [ -e /dev/ttyUSB0 ]; then
    PORT="/dev/ttyUSB0"
elif [ -e /dev/ttyACM1 ]; then
    PORT="/dev/ttyACM1"
else
    echo "ERROR: No device found on /dev/ttyACM0 or /dev/ttyUSB0"
    echo "Please check connection and try again."
    exit 1
fi

echo "Using port: $PORT"
echo ""

# Flash with all components
esptool --chip esp32s3 \
    --port $PORT \
    --baud 460800 \
    --before default_reset \
    --after hard_reset \
    write_flash \
    -z \
    --flash_mode dio \
    --flash_freq 80m \
    --flash_size 16MB \
    0x0 .pio/build/T_Beam_1W_SX1262_companion_radio_ble/bootloader.bin \
    0x8000 .pio/build/T_Beam_1W_SX1262_companion_radio_ble/partitions.bin \
    0x10000 .pio/build/T_Beam_1W_SX1262_companion_radio_ble/firmware.bin

if [ $? -eq 0 ]; then
    echo ""
    echo "================================================"
    echo "✓ Flash completed successfully!"
    echo "================================================"
    echo ""
    echo "Device should reboot automatically."
    echo "Press RESET button if nothing happens."
    echo ""
    echo "To monitor serial output:"
    echo "  pio device monitor --port $PORT"
else
    echo ""
    echo "================================================"
    echo "✗ Flash failed!"
    echo "================================================"
    echo ""
    echo "Try again and make sure device is in download mode."
fi
