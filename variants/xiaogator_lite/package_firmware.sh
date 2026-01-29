#!/bin/bash
# Package XiaGator Lite firmware for distribution
# Creates both UF2 files and manifest packages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MESHCORE_ROOT="$SCRIPT_DIR/../../.."
BUILD_DIR="$MESHCORE_ROOT/.pio/build"
OUTPUT_DIR="$MESHCORE_ROOT/firmware_packages/xiaogator_lite"
VERSION=$(date +%Y%m%d)

echo "=========================================="
echo "XiaGator Lite Firmware Packager"
echo "=========================================="
echo ""
echo "Version: $VERSION"
echo "Output: $OUTPUT_DIR"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Array of firmware variants
VARIANTS=(
    "XaioGator_Lite_companion_radio_ble:companion_ble:Companion Radio (Bluetooth)"
    "XaioGator_Lite_companion_radio_usb:companion_usb:Companion Radio (USB)"
    "XaioGator_Lite_repeater:repeater:Repeater"
    "XaioGator_Lite_room_server:room_server:Room Server"
)

# Process each variant
for VARIANT_INFO in "${VARIANTS[@]}"; do
    IFS=':' read -r ENV_NAME SHORT_NAME DISPLAY_NAME <<< "$VARIANT_INFO"
    
    echo "=========================================="
    echo "Packaging: $DISPLAY_NAME"
    echo "=========================================="
    
    # Create variant output directory
    VARIANT_DIR="$OUTPUT_DIR/$SHORT_NAME"
    mkdir -p "$VARIANT_DIR"
    
    # Find UF2 file
    UF2_FILE="$BUILD_DIR/$ENV_NAME/firmware.uf2"
    HEX_FILE="$BUILD_DIR/$ENV_NAME/firmware.hex"
    BIN_FILE="$BUILD_DIR/$ENV_NAME/firmware.bin"
    
    if [ -f "$UF2_FILE" ]; then
        # Copy UF2 file
        cp "$UF2_FILE" "$VARIANT_DIR/${ENV_NAME}.uf2"
        echo "✓ Copied UF2 file"
        
        # Create manifest.json for web flasher compatibility
        cat > "$VARIANT_DIR/manifest.json" << EOF
{
  "name": "XiaGator Lite - $DISPLAY_NAME",
  "version": "$VERSION",
  "new_install_prompt_erase": false,
  "builds": [
    {
      "chipFamily": "NRF52",
      "parts": [
        {
          "path": "${ENV_NAME}.uf2",
          "offset": 0
        }
      ]
    }
  ]
}
EOF
        echo "✓ Created manifest.json"
        
        # Copy hex file if exists
        if [ -f "$HEX_FILE" ]; then
            cp "$HEX_FILE" "$VARIANT_DIR/firmware.hex"
            echo "✓ Copied HEX file"
        fi
        
        # Copy bin file if exists
        if [ -f "$BIN_FILE" ]; then
            cp "$BIN_FILE" "$VARIANT_DIR/firmware.bin"
            echo "✓ Copied BIN file"
        fi
        
        # Create README
        cat > "$VARIANT_DIR/README.txt" << EOF
XiaGator Lite - $DISPLAY_NAME
Version: $VERSION
Build Date: $(date)

Hardware: Seeed XIAO nRF52840 + Ebyte E22-900M33S
Frequency: 915.0 MHz (US)
TX Power: 9 dBm (MAX - DO NOT EXCEED)

FLASHING INSTRUCTIONS:
======================

1. Connect XiaGator Lite via USB-C
2. Double-tap the reset button on the XIAO board
3. A drive named "XIAO-SENSE" will appear
4. Drag and drop "${ENV_NAME}.uf2" to the drive
5. Board will automatically reboot with new firmware

FILES:
======
- ${ENV_NAME}.uf2       : UF2 bootloader file (drag & drop)
- firmware.hex          : Intel HEX format (for programmers)
- firmware.bin          : Raw binary (for advanced users)
- manifest.json         : Web flasher manifest

WARNINGS:
=========
⚠️ TX Power is limited to 9 dBm
⚠️ Higher power WILL DESTROY the E22-900M33S module
⚠️ This is Amateur Radio equipment (Part 97)
⚠️ Requires license to operate legally in USA

Support: https://discord.gg/BMwCtwHj5V
Hardware: https://github.com/wehooper4/Meshtastic-Hardware
EOF
        echo "✓ Created README.txt"
        
        # Create ZIP package
        cd "$OUTPUT_DIR"
        zip -q -r "${SHORT_NAME}_v${VERSION}.zip" "$SHORT_NAME"
        echo "✓ Created ZIP: ${SHORT_NAME}_v${VERSION}.zip"
        cd - > /dev/null
        
        # Get file sizes
        UF2_SIZE=$(du -h "$VARIANT_DIR/${ENV_NAME}.uf2" | cut -f1)
        ZIP_SIZE=$(du -h "$OUTPUT_DIR/${SHORT_NAME}_v${VERSION}.zip" | cut -f1)
        
        echo ""
        echo "Package Summary:"
        echo "  UF2 file: $UF2_SIZE"
        echo "  ZIP file: $ZIP_SIZE"
        echo "  Location: $VARIANT_DIR"
        echo ""
        
    else
        echo "✗ UF2 file not found: $UF2_FILE"
        echo "  Build firmware first: platformio run -e $ENV_NAME -t create_uf2"
        echo ""
    fi
done

echo "=========================================="
echo "Packaging Complete!"
echo "=========================================="
echo ""
echo "Output directory:"
echo "  $OUTPUT_DIR"
echo ""
echo "Package contents:"
ls -lh "$OUTPUT_DIR"/*.zip 2>/dev/null || echo "  No ZIP files created"
echo ""
echo "Each package contains:"
echo "  - .uf2 file (drag & drop to XIAO-SENSE drive)"
echo "  - .hex file (for programmers)"
echo "  - .bin file (raw binary)"
echo "  - manifest.json (web flasher compatibility)"
echo "  - README.txt (instructions)"
echo ""
echo "Distribution options:"
echo "  1. Share individual .uf2 files (easiest for users)"
echo "  2. Share .zip packages (complete with documentation)"
echo "  3. Host on web server for web flasher tools"
echo ""
