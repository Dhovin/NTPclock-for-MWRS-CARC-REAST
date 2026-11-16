#!/usr/bin/env bash
# Automated dependency & display-pin installer for NTP Dual Clock (CARC v4 / ESP32-S3-mini)
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

USER_DIR=$(arduino-cli config get directories.user 2>/dev/null || echo "$HOME/Arduino")
USER_SETUP="$USER_DIR/libraries/TFT_eSPI/User_Setup.h"

if [ -f "$USER_SETUP" ]; then
  if ! grep -q "CARC_V4_ESP32S3_MINI" "$USER_SETUP"; then
    echo "Configuring TFT_eSPI User_Setup.h for CARC v4 (ESP32-S3-mini)..."
    python3 - "$USER_SETUP" <<'PY'
import re, sys
path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    text = f.read()
carc_pins = """// CARC_V4_ESP32S3_MINI display pins (matching NTP_Dual_Clock_MWRS_V4_x/tft_setup.h)
#define TFT_MOSI  11
#define TFT_MISO  12
#define TFT_SCLK  13
#define TFT_RST    5
#define TFT_CS     6
#define TFT_DC     7
#define TFT_RGB_ORDER TFT_BRG"""
text = re.sub(r"// For NodeMCU - use pin numbers.*?#define TFT_RST\s+PIN_D4[^\n]*", carc_pins, text, flags=re.S)
text = text.replace("//#define USE_HSPI_PORT", "#define USE_HSPI_PORT")
with open(path, "w", encoding="utf-8") as f:
    f.write(text)
PY
    echo "Updated $USER_SETUP"
  else
    echo "User_Setup.h already configured for CARC_V4_ESP32S3_MINI."
  fi
else
  echo "Warning: Could not find $USER_SETUP. Please configure TFT_eSPI User_Setup.h manually (see README.md)."
fi

echo ""
echo "Setup complete! Open NTP_Dual_Clock_MWRS_V4_x/NTP_Dual_Clock_MWRS_V4_x.ino in Arduino IDE."
