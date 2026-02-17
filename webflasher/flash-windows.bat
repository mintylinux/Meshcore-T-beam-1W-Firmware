@echo off
REM MeshCore T-Beam 1W Firmware Flasher for Windows
REM This script flashes MeshCore firmware to LilyGo T-Beam 1W devices

echo ========================================
echo MeshCore T-Beam 1W Firmware Flasher
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo.
    echo Please install Python from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    echo.
    pause
    exit /b 1
)

REM Check if esptool is installed
python -m esptool version >nul 2>&1
if errorlevel 1 (
    echo esptool is not installed. Installing now...
    pip install esptool
    if errorlevel 1 (
        echo ERROR: Failed to install esptool
        pause
        exit /b 1
    )
)

echo.
echo Available firmware types:
echo   1. Companion BLE (for use with mobile apps)
echo   2. Repeater (extends network coverage)
echo   3. Room Server (BBS server for shared posts)
echo.

set /p choice="Select firmware type (1-3): "

if "%choice%"=="1" (
    set FIRMWARE=merged\T-Beam-1W-CompanionBLE-v1.13.0.bin
    set FWNAME=Companion BLE
) else if "%choice%"=="2" (
    set FIRMWARE=merged\T-Beam-1W-Repeater-v1.13.0.bin
    set FWNAME=Repeater
) else if "%choice%"=="3" (
    set FIRMWARE=merged\T-Beam-1W-RoomServer-v1.13.0.bin
    set FWNAME=Room Server
)
    echo Invalid choice
    pause
    exit /b 1
)

if not exist "%FIRMWARE%" (
    echo ERROR: Firmware file not found: %FIRMWARE%
    echo Please make sure you're running this script from the webflasher directory
    pause
    exit /b 1
)

echo.
echo Selected: %FWNAME%
echo Firmware: %FIRMWARE%
echo.
echo Please connect your T-Beam 1W device via USB
echo.
echo Common COM ports: COM3, COM4, COM5, COM6
echo You can check Device Manager to find your port
echo.
set /p COMPORT="Enter COM port (e.g., COM5): "

echo.
echo ========================================
echo Flashing %FWNAME% firmware...
echo ========================================
echo.
echo Port: %COMPORT%
echo Chip: ESP32-S3
echo Baud: 460800
echo Offset: 0x0 (IMPORTANT!)
echo.

REM Erase flash first (recommended for clean install)
echo Step 1/2: Erasing flash...
python -m esptool --chip esp32s3 --port %COMPORT% erase_flash
if errorlevel 1 (
    echo.
    echo ERROR: Failed to erase flash
    echo.
    echo Troubleshooting:
    echo  - Check that the correct COM port is selected
    echo  - Try holding the BOOT button while plugging in USB
    echo  - Check that no other program is using the serial port
    pause
    exit /b 1
)

echo.
echo Step 2/2: Writing firmware...
python -m esptool --chip esp32s3 --port %COMPORT% --baud 460800 write_flash 0x0 "%FIRMWARE%"
if errorlevel 1 (
    echo.
    echo ERROR: Failed to write firmware
    pause
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS! Firmware flashed successfully
echo ========================================
echo.
echo The device should now reboot and start running %FWNAME% firmware.
echo.
echo Next steps:
if "%choice%"=="1" (
    echo  - Connect via MeshCore mobile app or web interface
    echo  - Web: https://app.meshcore.nz
    echo  - Android: https://play.google.com/store/apps/details?id=com.liamcottle.meshcore.android
    echo  - iOS: https://apps.apple.com/us/app/meshcore/id6742354151
) else (
    echo  - Configure via USB using: https://config.meshcore.dev
    echo  - Or manage via LoRa in the mobile app
)
echo.
pause
