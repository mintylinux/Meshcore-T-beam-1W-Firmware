#!/bin/bash
# Script to create properly merged firmware binaries for MeshCore Web Flasher
# These binaries will work with Web Serial API (Chrome/Edge browsers)

set -e

# Configuration
CHIP="esp32s3"
FLASH_MODE="dio"  # Must match PlatformIO (not qio!)
FLASH_FREQ="80m"
FLASH_SIZE="4MB"  # PlatformIO uses 4MB setting (board has 16MB physically)
VERSION="v1.13.0"

# Paths
BUILD_DIR=".pio/build"
OUTPUT_DIR="webflasher/merged"
BOOT_APP0="$HOME/.platformio/packages/framework-arduinoespressif32/tools/partitions/boot_app0.bin"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Creating MeshCore Web Flasher binaries..."
echo "==========================================="

# Function to create merged binary
create_merged_bin() {
    local env_name=$1
    local output_name=$2
    
    echo ""
    echo "Building: $output_name"
    
    local bootloader="${BUILD_DIR}/${env_name}/bootloader.bin"
    local partitions="${BUILD_DIR}/${env_name}/partitions.bin"
    local firmware="${BUILD_DIR}/${env_name}/firmware.bin"
    local output="${OUTPUT_DIR}/${output_name}"
    
    # Check if all required files exist
    if [ ! -f "$bootloader" ]; then
        echo "ERROR: Bootloader not found at $bootloader"
        echo "Please build the firmware first: pio run -e $env_name"
        return 1
    fi
    
    if [ ! -f "$partitions" ]; then
        echo "ERROR: Partitions not found at $partitions"
        return 1
    fi
    
    if [ ! -f "$firmware" ]; then
        echo "ERROR: Firmware not found at $firmware"
        return 1
    fi
    
    if [ ! -f "$BOOT_APP0" ]; then
        echo "ERROR: boot_app0.bin not found at $BOOT_APP0"
        return 1
    fi
    
    # Create merged binary with all components including boot_app0.bin
    python3 -m esptool --chip "$CHIP" merge_bin \
        -o "$output" \
        --flash_mode "$FLASH_MODE" \
        --flash_freq "$FLASH_FREQ" \
        --flash_size "$FLASH_SIZE" \
        0x0 "$bootloader" \
        0x8000 "$partitions" \
        0xe000 "$BOOT_APP0" \
        0x10000 "$firmware"
    
    if [ $? -eq 0 ]; then
        echo "✓ Created: $output ($(ls -lh "$output" | awk '{print $5}'))"
    else
        echo "✗ Failed to create $output"
        return 1
    fi
}

# Create binaries for all three firmware types
create_merged_bin "LilyGo_TBeam_1W_companion_radio_ble" "T-Beam-1W-CompanionBLE-${VERSION}.bin"
create_merged_bin "LilyGo_TBeam_1W_repeater" "T-Beam-1W-Repeater-${VERSION}.bin"
create_merged_bin "LilyGo_TBeam_1W_room_server" "T-Beam-1W-RoomServer-${VERSION}.bin"

echo ""
echo "==========================================="
echo "✓ All binaries created successfully!"
echo ""
echo "Binaries are ready for MeshCore Web Flasher in:"
echo "  $OUTPUT_DIR/"
echo ""
echo "These binaries include:"
echo "  - Bootloader (0x0000)"
echo "  - Partition table (0x8000)"
echo "  - boot_app0.bin (0xe000) ← REQUIRED for web flashers!"
echo "  - Application firmware (0x10000)"
echo ""
echo "Flash mode: $FLASH_MODE (Dual I/O - matches PlatformIO)"
echo "Flash freq: $FLASH_FREQ"
echo "Flash size: $FLASH_SIZE (PlatformIO setting)"
echo ""
echo "To flash with esptool:"
echo "  python3 -m esptool --chip esp32s3 --port /dev/ttyACM5 --baud 460800 write_flash 0x0 $OUTPUT_DIR/T-Beam-1W-CompanionBLE-${VERSION}.bin"
echo ""
echo "Note: MeshCore webflasher currently flashes at wrong offset (0x10000)."
echo "Use esptool directly until webflasher is updated."
