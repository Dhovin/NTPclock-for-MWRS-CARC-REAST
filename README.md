# NTP Dual Clock — CARC v4 (ESP32-S3-mini)

- **Original Author:** Bruce E. Hall, [w8bh.net](https://w8bh.net)
- **Current Maintainers:** RAHinsley (VK2ARH), MJCulross (KD5RXT)
- **Hardware:** CARC v4 PCB with **ESP32-S3-mini** (`LOLIN S3 Mini`) and ILI9341 240x320 TFT display
- **License:** MIT License (see [LICENSE](LICENSE))

Dual UTC/Local NTP Clock with TFT display. Time is refreshed via NTP and/or an optional GPS receiver, with status indicators for time freshness, Wi-Fi strength, battery voltage, solar weather, local environmental data (BME280/BMP280), internet weather, and Maidenhead Grid Square (MLS).

- **Full Operating & Configuration Manual:** [Software documentation/20261104 - NTPclock Software Documentation.pdf](Software%20documentation/20261104%20-%20NTPclock%20Software%20Documentation.pdf)
- **CARC Kit Build Instructions:** [20261108 - NTPclock v4 for CARC Kit Build Instructions.pdf](20261108%20-%20NTPclock%20v4%20for%20CARC%20Kit%20Build%20Instructions.pdf)
- **Original W8BH Reference:** [W8BH NTP_DualClock.pdf](https://w8bh.net/NTP_DualClock.pdf) *(targets the older ESP32-WROOM-32; use the CARC v4 pinouts below)*
- **Revision History:** [README.txt](README.txt)

---

## Overview: What Gets Installed Where

- **On your PC:** You install **Arduino IDE**, the **Espressif ESP32 board support package**, and the **12 required Arduino libraries**. Arduino IDE compiles the source code and flashes it over USB to the ESP32-S3-mini.
- **On the ESP32-S3-mini:** You flash the **NTPclock firmware** built from [NTP_Dual_Clock_MWRS_V4_x/NTP_Dual_Clock_MWRS_V4_x.ino](NTP_Dual_Clock_MWRS_V4_x/NTP_Dual_Clock_MWRS_V4_x.ino) (along with [tft_setup.h](NTP_Dual_Clock_MWRS_V4_x/tft_setup.h), [UserSettings.h](NTP_Dual_Clock_MWRS_V4_x/UserSettings.h), and [Certificate.h](NTP_Dual_Clock_MWRS_V4_x/Certificate.h)). No separate OS or pre-installed firmware is needed on the ESP32-S3-mini.

---

## Step-by-Step Installation Guide

### Step 1: Install Software on Your PC

1. **Install Arduino IDE:**
   - Download and install **Arduino IDE** from [https://www.arduino.cc/en/software](https://www.arduino.cc/en/software) (tested with **2.3.10** and **1.8.19**).
2. **USB Cable:**
   - Use a **USB-C data cable** (not a charge-only cable) to connect the ESP32-S3-mini to your PC.
   - The LOLIN S3 Mini uses native USB CDC, so Windows 10/11, macOS, and Linux normally recognize it without external serial drivers.

---

### Step 2: Download This Repository

Download the CARC v4 fork:
- **Option A (ZIP):** Go to [https://github.com/Dhovin/NTPclock-for-MWRS-CARC-REAST](https://github.com/Dhovin/NTPclock-for-MWRS-CARC-REAST), click **Code > Download ZIP**, and extract it.
- **Option B (Git):**
  ```bash
  git clone https://github.com/Dhovin/NTPclock-for-MWRS-CARC-REAST.git
  ```

The Arduino sketch is in [NTP_Dual_Clock_MWRS_V4_x/](NTP_Dual_Clock_MWRS_V4_x/), already pre-configured for **`CARC_V4_ESP32S3_MINI`** in [tft_setup.h](NTP_Dual_Clock_MWRS_V4_x/tft_setup.h).

---

### Step 3: Install ESP32 Board Support, Libraries & Display Pins

#### Option A: Automated Setup (Recommended)

Run the included setup script from the repository root. It installs `arduino-cli` (via `winget` on Windows if needed), adds the Espressif board URL, installs `esp32:esp32@3.3.10`, installs all 12 libraries, **and automatically configures `TFT_eSPI`'s `User_Setup.h` for the CARC v4 pins**:

- **Windows (PowerShell):**
  ```powershell
  .\install_deps.ps1
  ```
- **macOS / Linux:**
  ```bash
  chmod +x install_deps.sh && ./install_deps.sh
  ```
  *(On macOS, install `arduino-cli` first with `brew install arduino-cli`; see [Arduino CLI installation](https://arduino.github.io/arduino-cli/latest/installation/).)*

If you used Option A, skip ahead to **Step 4**.

#### Option B: Manual Setup in Arduino IDE

1. **ESP32 Board Support:**
   - Open Arduino IDE **File > Preferences** (macOS: **Arduino IDE > Settings**).
   - Add to **Additional Boards Manager URLs**:
     ```text
     https://espressif.github.io/arduino-esp32/package_esp32_index.json
     ```
   - Open **Tools > Board > Boards Manager...**, search for **`esp32`**, and install **`esp32` by Espressif Systems** (tested version **`3.3.10`**). See [Espressif installation docs](https://docs.espressif.com/projects/arduino-esp32/en/latest/installing.html).

2. **Install Required Libraries** (**Sketch > Include Library > Manage Libraries...**):

   | Library | Author | Tested Version | Link / Notes |
   | --- | --- | --- | --- |
   | **TFT_eSPI** | Bodmer | `2.5.43` | [GitHub](https://github.com/Bodmer/TFT_eSPI) |
   | **ezTime** | Rop Gonggrijp | `0.8.3` | [GitHub](https://github.com/ropg/ezTime) |
   | **ArduinoJson** | Benoit Blanchon | `7.4.3` | [arduinojson.org](https://arduinojson.org/) |
   | **Button2** | Lennart Hennigs | `2.7.0` | [GitHub](https://github.com/LennartHennigs/Button2) |
   | **ESP Async WebServer** | ESP32Async | `3.12.1` | [GitHub](https://github.com/ESP32Async/ESPAsyncWebServer) |
   | **Async TCP** | ESP32Async | `3.5.0` | [GitHub](https://github.com/ESP32Async/AsyncTCP) |
   | **TinyGPSPlus** | Mikal Hart | `1.0.3` | [GitHub](https://github.com/mikalhart/TinyGPSPlus) |
   | **SparkFun u-blox GNSS Arduino Library** | SparkFun Electronics | `2.2.29` | [GitHub](https://github.com/sparkfun/SparkFun_u-blox_GNSS_Arduino_Library) |
   | **EspSoftwareSerial** | Dirk Kaar | `8.1.0` | [GitHub](https://github.com/plerup/espsoftwareserial) |
   | **Preferences** | Volodymyr Shymanskyy | `2.4.0` | Install via Library Manager |
   | **Adafruit BME280 Library** | Adafruit | `2.3.0` | [GitHub](https://github.com/adafruit/Adafruit_BME280_Library) — click **Install all** |
   | **Adafruit BMP280 Library** | Adafruit | `3.0.0` | [GitHub](https://github.com/adafruit/Adafruit_BMP280_Library) — click **Install all** |

3. **Configure `TFT_eSPI` Display Pins (`User_Setup.h`):**
   - **Quickest manual method:** Copy [TFT_eSPI_User_Setup.h](TFT_eSPI_User_Setup.h) from this repository over `<Sketchbook location>/libraries/TFT_eSPI/User_Setup.h` (typically `Documents/Arduino/libraries/TFT_eSPI/User_Setup.h`; check **File > Preferences > Sketchbook location** in Arduino IDE).
   - **Or edit `User_Setup.h` by hand:** Ensure `#define ILI9341_DRIVER`, `#define USE_HSPI_PORT`, and the fonts (`LOAD_GLCD`, `LOAD_FONT2/4/6/7/8`, `LOAD_GFXFF`) are uncommented, and replace the default `TFT_MISO`/`TFT_MOSI`/`TFT_SCLK`/`TFT_CS`/`TFT_DC`/`TFT_RST` pin definitions with the CARC v4 pins:
     ```cpp
     #define TFT_MOSI  11
     #define TFT_MISO  12
     #define TFT_SCLK  13
     #define TFT_RST    5
     #define TFT_CS     6
     #define TFT_DC     7
     #define TFT_RGB_ORDER TFT_BRG
     ```

---

### Step 4: (Optional) Customize Defaults in `UserSettings.h`

Before compiling, you can optionally edit [NTP_Dual_Clock_MWRS_V4_x/UserSettings.h](NTP_Dual_Clock_MWRS_V4_x/UserSettings.h) to set defaults such as `DEFAULT_TITLE` (up to 8 characters, e.g., your callsign), `timeZones[]`, or `DEFAULT_AP_NAME` (default `"NTPCLOCK_AP"`). Most settings can also be changed later from the clock's web interface.

---

### Step 5: Configure Board Settings in Arduino IDE

Open [NTP_Dual_Clock_MWRS_V4_x/NTP_Dual_Clock_MWRS_V4_x.ino](NTP_Dual_Clock_MWRS_V4_x/NTP_Dual_Clock_MWRS_V4_x.ino) in Arduino IDE and set the **Tools** menu as follows:

- **Board:** `LOLIN S3 Mini` (under **Tools > Board > esp32**)
- **Upload Speed:** `921600`
- **USB Mode:** `Hardware CDC and JTAG`
- **USB CDC On Boot:** `Enabled`
- **USB Firmware MSC On Boot:** `Disabled`
- **USB DFU On Boot:** `Disabled`
- **Upload Mode:** `UART0 / Hardware CDC`
- **CPU Frequency:** `240MHz (WiFi)`
- **Flash Mode:** `QIO 80MHz`
- **Partition Scheme:** `Huge App (3MB No OTA/1MB SPIFFS)`
- **Core Debug Level:** `None`
- **Arduino Runs On:** `Core 1`
- **Events Run On:** `Core 1`
- **Erase All Flash Before Sketch Upload:** `Disabled`

---

### Step 6: Flash the Firmware to the ESP32-S3-mini

1. Connect the ESP32-S3-mini to your PC with a **USB-C data cable**.
2. **First-time upload only:** Put the board into bootloader mode manually:
   1. Press and hold **`0`** (or **`BOOT`**).
   2. Press and release **`RST`** (or **`RESET`**).
   3. Release **`0`** (or **`BOOT`**).
3. Select the port under **Tools > Port** (on Windows, check **Device Manager > Ports (COM & LPT)**).
4. Click **Upload**.
5. Once uploading finishes, press **`RST`** once on the ESP32-S3-mini to boot the firmware. *(Manual bootloader mode is not needed for subsequent uploads.)*

---

### Step 7: First-Boot Setup on the Clock

1. Power on the clock. It hosts a Wi-Fi Access Point named **`NTPCLOCK_AP`** by default.
2. Connect your phone or PC to **`NTPCLOCK_AP`** and open **`http://10.1.1.1`** in a browser.
3. On the **NETWORK** tab, enter up to 6 Wi-Fi networks (SSID and password) and click **Save/Apply**.
4. On the **CONFIG** tab, set your banner title/callsign, timezones, GPS mode, display options, and (for internet weather) your free OpenWeatherMap API key from [https://home.openweathermap.org/users/sign_up](https://home.openweathermap.org/users/sign_up).
5. Click **Save/Apply**.
