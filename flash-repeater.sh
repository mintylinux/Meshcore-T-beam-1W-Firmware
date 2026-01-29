#!/bin/bash
# Flash T-Beam 1W Repeater firmware

echo "Put device in download mode (HOLD BOOT, PRESS/RELEASE RESET, RELEASE BOOT)"
echo "Press Enter when ready..."
read

PORT=""
if [ -e /dev/ttyACM1 ]; then PORT="/dev/ttyACM1"
elif [ -e /dev/ttyACM0 ]; then PORT="/dev/ttyACM0"
elif [ -e /dev/ttyUSB0 ]; then PORT="/dev/ttyUSB0"
fi

echo "Using port: $PORT"

esptool --chip esp32s3 --port $PORT --baud 460800 \
  --before default_reset --after hard_reset write_flash -z \
  --flash_mode dio --flash_freq 80m --flash_size 16MB \
  0x0 .pio/build/T_Beam_1W_SX1262_repeater/bootloader.bin \
  0x8000 .pio/build/T_Beam_1W_SX1262_repeater/partitions.bin \
  0x10000 .pio/build/T_Beam_1W_SX1262_repeater/firmware.bin

echo ""
echo "Flash complete! Device should reboot."
echo "To see serial output: python3 -c \"import serial; s = serial.Serial('$PORT', 115200); [print(line.decode('utf-8', errors='ignore'), end='') for line in iter(s.readline, b'')]\""
