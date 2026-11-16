# Automated dependency & display-pin installer for NTP Dual Clock (CARC v4 / ESP32-S3-mini)
# Requires Arduino CLI: https://arduino.github.io/arduino-cli/latest/installation/

$ErrorActionPreference = "Stop"

if (-not (Get-Command arduino-cli -ErrorAction SilentlyContinue)) {
    Write-Host "arduino-cli not found. Installing via winget..." -ForegroundColor Yellow
    winget install ArduinoSA.CLI
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (-not (Get-Command arduino-cli -ErrorAction SilentlyContinue)) {
        Write-Host "Please restart your terminal so arduino-cli is on PATH, then re-run this script." -ForegroundColor Cyan
        exit 0
    }
}

Write-Host "Configuring Arduino CLI..." -ForegroundColor Cyan
if (-not (Test-Path "$env:LOCALAPPDATA\Arduino15\arduino-cli.yaml")) {
    arduino-cli config init
}
arduino-cli config set board_manager.additional_urls "https://espressif.github.io/arduino-esp32/package_esp32_index.json"
arduino-cli core update-index

Write-Host "Installing ESP32 board package (3.3.10)..." -ForegroundColor Cyan
arduino-cli core install esp32:esp32@3.3.10

$libraries = @(
    "TFT_eSPI@2.5.43",
    "ezTime@0.8.3",
    "ArduinoJson@7.4.3",
    "Button2@2.7.0",
    "ESP Async WebServer@3.12.1",
    "Async TCP@3.5.0",
    "TinyGPSPlus@1.0.3",
    "SparkFun u-blox GNSS Arduino Library@2.2.29",
    "EspSoftwareSerial@8.1.0",
    "Preferences@2.4.0",
    "Adafruit BME280 Library@2.3.0",
    "Adafruit BMP280 Library@3.0.0"
)

foreach ($lib in $libraries) {
    Write-Host "Installing library: $lib" -ForegroundColor Cyan
    arduino-cli lib install "$lib"
}

# Configure TFT_eSPI User_Setup.h for CARC_V4_ESP32S3_MINI
$userDir = (arduino-cli config get directories.user 2>$null)
if (-not $userDir) { $userDir = Join-Path $env:USERPROFILE "Documents\Arduino" }
$userSetup = Join-Path $userDir "libraries\TFT_eSPI\User_Setup.h"

if (Test-Path $userSetup) {
    Write-Host "Configuring TFT_eSPI User_Setup.h for CARC v4 (ESP32-S3-mini)..." -ForegroundColor Cyan
    $content = Get-Content $userSetup -Raw
    if ($content -notmatch "CARC_V4_ESP32S3_MINI") {
        $carcPins = @"
// CARC_V4_ESP32S3_MINI display pins (matching NTP_Dual_Clock_MWRS_V4_x/tft_setup.h)
#define TFT_MOSI  11
#define TFT_MISO  12
#define TFT_SCLK  13
#define TFT_RST    5
#define TFT_CS     6
#define TFT_DC     7
#define TFT_RGB_ORDER TFT_BRG
"@
        $content = $content -replace "(?s)// For NodeMCU - use pin numbers.*?#define TFT_RST\s+PIN_D4[^\r\n]*", $carcPins
        $content = $content -replace "//#define USE_HSPI_PORT", "#define USE_HSPI_PORT"
        Set-Content -Path $userSetup -Value $content -NoNewline
        Write-Host "Updated $userSetup" -ForegroundColor Green
    } else {
        Write-Host "User_Setup.h already configured for CARC_V4_ESP32S3_MINI." -ForegroundColor Green
    }
} else {
    Write-Warning "Could not find $userSetup. Please configure TFT_eSPI User_Setup.h manually (see README.md)."
}

Write-Host "`nSetup complete! Open NTP_Dual_Clock_MWRS_V4_x/NTP_Dual_Clock_MWRS_V4_x.ino in Arduino IDE." -ForegroundColor Green
