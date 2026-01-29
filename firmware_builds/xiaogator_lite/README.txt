========================================
XaioGator Lite Firmware - Build Success!
========================================

✓ All 4 firmware variants have been successfully built!

Files in this directory:
------------------------

1. XaioGator_Lite_companion_radio_ble.uf2 (829KB)
   - For smartphone connectivity via Bluetooth
   - Use with MeshCore Android/iOS apps
   - BLE PIN: 123456
   - 350 contacts, 40 channels

2. XaioGator_Lite_companion_radio_usb.uf2 (803KB)
   - For computer connectivity via USB serial
   - Use with terminal or Python CLI
   - 350 contacts, 40 channels

3. XaioGator_Lite_repeater.uf2 (794KB)
   - Mesh network range extender
   - Automatically relays messages
   - 50 max neighbors
   - Default admin password: "password"

4. XaioGator_Lite_room_server.uf2 (778KB)
   - BBS-style message board
   - Shared posts for all users
   - Default admin password: "password"


How to Flash:
-------------

1. Connect XaioGator Lite via USB-C cable
2. Double-tap the reset button on the XIAO board
3. A drive named "XIAO-SENSE" will appear
4. Drag & drop the .uf2 file you want to the drive
5. Board automatically reboots with new firmware
6. Done!


⚠️ IMPORTANT SAFETY WARNING ⚠️
--------------------------------

The E22-900M33S module is configured with a MAXIMUM
TX power of 9 dBm. DO NOT attempt to increase this!

Higher power WILL PERMANENTLY DAMAGE the radio module.


After Flashing:
---------------

Companion Radio (BLE):
- Install MeshCore app on your phone
- Android: https://play.google.com/store/apps/details?id=com.liamcottle.meshcore.android
- iOS: https://apps.apple.com/us/app/meshcore/id6742354151
- Connect to "XIAO nRF52840" via Bluetooth

Companion Radio (USB):
- Connect via serial terminal:
  screen /dev/ttyACM0 115200
  or: platformio device monitor

Repeater/Room Server:
- Powers on and starts automatically
- Configure via serial console or remote management
- Change default admin password!


Hardware Specs:
---------------

MCU: Seeed XIAO nRF52840 (Nordic nRF52840)
Radio: Ebyte E22-900M33S (SX1262)
Frequency: 902-928 MHz
TX Power: 9 dBm MAX (hardware safety limit)
RX Sensitivity: -148 dBm
Bluetooth: BLE 5.0
Flash: 1MB + QSPI external
RAM: 256KB


Support & Resources:
--------------------

MeshCore:
- GitHub: https://github.com/meshcore-dev/MeshCore
- Discord: https://discord.gg/BMwCtwHj5V
- Web Client: https://app.meshcore.nz
- Config Tool: https://config.meshcore.dev

Hardware:
- XaioGator Design: https://github.com/wehooper4/Meshtastic-Hardware
- Documentation: ~/Desktop/MeshCore/variants/xiaogator_lite/


Legal Notice:
-------------

This is Amateur Radio equipment under FCC Part 97.
- Not certified for unlicensed operation
- Requires amateur radio license in USA
- Users must comply with local regulations

Hardware License: CC BY-NC-SA 4.0 (WeHooper4)
Firmware License: MIT License (MeshCore)


Build Info:
-----------

Build Date: 2026-01-04
Build Tool: PlatformIO Core 6.1.18
Platform: Nordic nRF52 10.10.0
Framework: Arduino (Adafruit nRF52)
Configuration: MeshCore custom variant

Built on: Manjaro Linux
Location: /home/chuck/Desktop/MeshCore


Need Help?
----------

See documentation in:
~/Desktop/MeshCore/variants/xiaogator_lite/

- INDEX.md - Overview and navigation
- INSTALL.md - Installation guide
- QUICKSTART.md - Quick start guide
- README.md - Technical documentation

Or join the MeshCore Discord for community support!

========================================
