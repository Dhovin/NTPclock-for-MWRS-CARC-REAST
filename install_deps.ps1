# Automated dependency installer for NTP Dual Clock (Windows PowerShell)
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

Write-Host "`nAll board packages and libraries installed!" -ForegroundColor Green
Write-Host "Next: configure TFT_eSPI's User_Setup.h (Step 6 in README.md) and select your target in tft_setup.h." -ForegroundColor Yellow
