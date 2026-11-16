#!/usr/bin/env bash
# Automated dependency installer for NTP Dual Clock (macOS / Linux)
# Requires Arduino CLI: https://arduino.github.io/arduino-cli/latest/installation/

set -euo pipefail

if ! command -v arduino-cli >/dev/null 2>&1; then
  echo "arduino-cli not found. Install it from: https://arduino.github.io/arduino-cli/latest/installation/"
  echo "On macOS with Homebrew: brew install arduino-cli"
  exit 1
fi

echo "Configuring Arduino CLI..."
arduino-cli config init --overwrite 2>/dev/null || true
arduino-cli config set board_manager.additional_urls "https://espressif.github.io/arduino-esp32/package_esp32_index.json"
arduino-cli core update-index

echo "Installing ESP32 board package (3.3.10)..."
arduino-cli core install esp32:esp32@3.3.10

LIBRARIES=(
  "TFT_eSPI@2.5.43"
  "ezTime@0.8.3"
  "ArduinoJson@7.4.3"
  "Button2@2.7.0"
  "ESP Async WebServer@3.12.1"
  "Async TCP@3.5.0"
  "TinyGPSPlus@1.0.3"
  "SparkFun u-blox GNSS Arduino Library@2.2.29"
  "EspSoftwareSerial@8.1.0"
  "Preferences@2.4.0"
  "Adafruit BME280 Library@2.3.0"
  "Adafruit BMP280 Library@3.0.0"
)

for lib in "${LIBRARIES[@]}"; do
  echo "Installing library: $lib"
  arduino-cli lib install "$lib"
done

echo ""
echo "All board packages and libraries installed!"
echo "Next: configure TFT_eSPI's User_Setup.h (Step 6 in README.md) and select your target in tft_setup.h."
