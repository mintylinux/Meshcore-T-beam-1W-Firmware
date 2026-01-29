#!/bin/bash
# Build script for XaioGator Lite firmware UF2 files
# This creates flashable UF2 files for all firmware variants

set -e  # Exit on error

echo "=========================================="
echo "XaioGator Lite Firmware Builder"
echo "=========================================="
echo ""

# Check if PlatformIO is installed
if ! command -v platformio &> /dev/null; then
    echo "ERROR: PlatformIO is not installed!"
    echo ""
    echo "Install PlatformIO first:"
    echo "  sudo pacman -S platformio-core"
    echo ""
    exit 1
fi

# Use 'platformio' command
PIO_CMD="platformio"

# Get the MeshCore root directory
if [ -f "platformio.ini" ]; then
    # Already in MeshCore root
    SCRIPT_DIR="$(pwd)"
else
    # Navigate to MeshCore root from script location
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../.." && pwd )"
    cd "$SCRIPT_DIR"
fi

echo "Working directory: $SCRIPT_DIR"
echo ""

# Output directory for UF2 files
OUTPUT_DIR="$SCRIPT_DIR/firmware_builds/xiaogator_lite"
mkdir -p "$OUTPUT_DIR"

# Array of environments to build
ENVIRONMENTS=(
    "XaioGator_Lite_companion_radio_ble"
    "XaioGator_Lite_companion_radio_usb"
    "XaioGator_Lite_repeater"
    "XaioGator_Lite_room_server"
)

# Build each environment
for ENV in "${ENVIRONMENTS[@]}"; do
    echo "=========================================="
    echo "Building: $ENV"
    echo "=========================================="
    
    # Clean previous build
    $PIO_CMD run -e "$ENV" -t clean
    
    # Build the firmware
    if $PIO_CMD run -e "$ENV"; then
        echo ""
        echo "✓ Build successful: $ENV"
        
        # Create UF2 file
        echo "Creating UF2 file..."
        $PIO_CMD run -e "$ENV" -t create_uf2
        
        # Find the generated UF2 file
        UF2_FILE=$(find .pio/build/$ENV -name "*.uf2" | head -n 1)
        
        if [ -n "$UF2_FILE" ]; then
            # Copy to output directory with descriptive name
            OUTPUT_FILE="$OUTPUT_DIR/${ENV}.uf2"
            cp "$UF2_FILE" "$OUTPUT_FILE"
            
            # Get file size
            SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
            
            echo "✓ UF2 file created: $OUTPUT_FILE ($SIZE)"
            echo ""
        else
            echo "⚠ Warning: UF2 file not found for $ENV"
            echo "  Check if create-uf2.py script ran successfully"
            echo ""
        fi
    else
        echo ""
        echo "✗ Build failed: $ENV"
        echo ""
        exit 1
    fi
done

echo "=========================================="
echo "Build Complete!"
echo "=========================================="
echo ""
echo "UF2 files are located in:"
echo "  $OUTPUT_DIR"
echo ""
echo "To flash:"
echo "  1. Double-tap reset button on XaioGator Lite"
echo "  2. Drag & drop the .uf2 file to the drive that appears"
echo ""
ls -lh "$OUTPUT_DIR"/*.uf2 2>/dev/null || echo "No UF2 files found"
echo ""
