# MeshCore T-Beam 1W Firmware Flasher for Windows (PowerShell)
# This script flashes MeshCore firmware to LilyGo T-Beam 1W devices

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MeshCore T-Beam 1W Firmware Flasher" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Python is installed
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✓ Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: Python is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Python from https://www.python.org/downloads/"
    Write-Host "Make sure to check 'Add Python to PATH' during installation"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if esptool is installed
try {
    python -m esptool version 2>&1 | Out-Null
    Write-Host "✓ esptool is installed" -ForegroundColor Green
} catch {
    Write-Host "Installing esptool..." -ForegroundColor Yellow
    pip install esptool
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ ERROR: Failed to install esptool" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""
Write-Host "Available firmware types:" -ForegroundColor Yellow
Write-Host "  1. Companion BLE (for use with mobile apps)"
Write-Host "  2. Repeater (extends network coverage)"
Write-Host "  3. Room Server (BBS server for shared posts)"
Write-Host ""

$choice = Read-Host "Select firmware type (1-3)"

switch ($choice) {
    "1" {
        $firmware = "merged\T-Beam-1W-CompanionBLE-v1.12.0.bin"
        $fwname = "Companion BLE"
    }
    "2" {
        $firmware = "merged\T-Beam-1W-Repeater-v1.12.0.bin"
        $fwname = "Repeater"
    }
    "3" {
        $firmware = "merged\T-Beam-1W-RoomServer-v1.12.0.bin"
        $fwname = "Room Server"
    }
    default {
        Write-Host "✗ Invalid choice" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

if (-not (Test-Path $firmware)) {
    Write-Host "✗ ERROR: Firmware file not found: $firmware" -ForegroundColor Red
    Write-Host "Please make sure you're running this script from the webflasher directory"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Selected: $fwname" -ForegroundColor Green
Write-Host "Firmware: $firmware" -ForegroundColor Gray
Write-Host ""
Write-Host "Please connect your T-Beam 1W device via USB" -ForegroundColor Yellow
Write-Host ""

# List available COM ports
Write-Host "Available COM ports:" -ForegroundColor Cyan
try {
    $ports = [System.IO.Ports.SerialPort]::GetPortNames()
    if ($ports.Count -gt 0) {
        foreach ($port in $ports) {
            Write-Host "  - $port" -ForegroundColor Gray
        }
    } else {
        Write-Host "  No COM ports detected" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  Unable to list ports. Common ports: COM3, COM4, COM5, COM6" -ForegroundColor Gray
}
Write-Host ""
Write-Host "You can also check Device Manager to find your port" -ForegroundColor Gray
Write-Host ""

$comport = Read-Host "Enter COM port (e.g., COM5)"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Flashing $fwname firmware..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Port:   $comport" -ForegroundColor Gray
Write-Host "Chip:   ESP32-S3" -ForegroundColor Gray
Write-Host "Baud:   460800" -ForegroundColor Gray
Write-Host "Offset: 0x0 (IMPORTANT!)" -ForegroundColor Yellow
Write-Host ""

# Erase flash first
Write-Host "Step 1/2: Erasing flash..." -ForegroundColor Yellow
python -m esptool --chip esp32s3 --port $comport erase_flash
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "✗ ERROR: Failed to erase flash" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  - Check that the correct COM port is selected"
    Write-Host "  - Try holding the BOOT button while plugging in USB"
    Write-Host "  - Check that no other program is using the serial port"
    Write-Host "  - Try running PowerShell as Administrator"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Write firmware
Write-Host ""
Write-Host "Step 2/2: Writing firmware..." -ForegroundColor Yellow
python -m esptool --chip esp32s3 --port $comport --baud 460800 write_flash 0x0 $firmware
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "✗ ERROR: Failed to write firmware" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "SUCCESS! Firmware flashed successfully" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "The device should now reboot and start running $fwname firmware." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow

if ($choice -eq "1") {
    Write-Host "  - Connect via MeshCore mobile app or web interface"
    Write-Host "  - Web: https://app.meshcore.nz"
    Write-Host "  - Android: https://play.google.com/store/apps/details?id=com.liamcottle.meshcore.android"
    Write-Host "  - iOS: https://apps.apple.com/us/app/meshcore/id6742354151"
} else {
    Write-Host "  - Configure via USB using: https://config.meshcore.dev"
    Write-Host "  - Or manage via LoRa in the mobile app"
}

Write-Host ""
Read-Host "Press Enter to exit"
