# NTP Dual Clock (MWRS / CARC / REAST)

- **Original Author:** Bruce E. Hall, [w8bh.net](https://w8bh.net)
- **Current Maintainers:** RAHinsley (VK2ARH), MJCulross (KD5RXT)
- **Hardware:** ESP32-S3-mini (recommended) or ESP32-S2-mini with ILI9341 240x320 TFT display
- **License:** MIT License (see [LICENSE](LICENSE))

Dual UTC/Local NTP Clock with TFT display. Time is refreshed via NTP and/or an optional GPS receiver, with status indicators for time freshness, Wi-Fi strength, supply/battery voltage, solar weather, local environmental data (BME280/BMP280), internet weather, and Maidenhead Grid Square (MLS).

For full operating instructions, button functions, and web configuration details, see [Software documentation/20261104 - NTPclock Software Documentation.pdf](Software%20documentation/20261104%20-%20NTPclock%20Software%20Documentation.pdf). For full revision history, see [README.txt](README.txt).

---

## Overview: What Gets Installed Where

- **On your PC:** You install **Arduino IDE**, the **Espressif ESP32 board support package**, and the **12 required Arduino libraries**. Arduino IDE compiles the source code from this repository and flashes it over USB to the microcontroller.
- **On the ESP32-S3-mini (or S2-mini):** You flash the **NTPclock firmware** built from [NTP_Dual_Clock_MWRS_V4_x.ino](NTP_Dual_Clock_MWRS_V4_x.ino) (along with [tft_setup.h](tft_setup.h), [UserSettings.h](UserSettings.h), and [Certificate.h](Certificate.h)). No separate OS or pre-installed firmware is needed on the ESP32—flashing overwrites the chip with the complete clock firmware.

### Which Processor Should I Use?

- **ESP32-S3-mini (Recommended):** Includes more RAM, allowing all features (Solar, Environmental, Weather, MLS, and GPS) to run simultaneously without restrictions.
- **ESP32-S2-mini:** Supported, but has limited RAM (320 KB). When GPS is enabled, solar data fetching is automatically suspended to avoid TLS handshake failures.

---

## Step-by-Step Installation Guide

### Step 1: Install Software on Your PC

1. **Install Arduino IDE:**
   - Download and install **Arduino IDE** from the official website: [https://www.arduino.cc/en/software](https://www.arduino.cc/en/software)
   - Both **Arduino IDE 2.x** (tested with `2.3.10`) and **Legacy IDE 1.8.x** (tested with `1.8.19`) work.
2. **USB Cable & Drivers:**
   - You will need a **USB-C data cable** (not a charge-only cable) to connect the ESP32-S3-mini / S2-mini to your PC.
   - The LOLIN S3 Mini and S2 Mini use native USB (CDC), so Windows 10/11, macOS, and Linux normally recognize the board without needing separate CP210x/CH340 drivers.

---

### Step 2: Download the NTPclock Firmware Source

1. Download this repository:
   - **Option A (ZIP):** Go to [https://github.com/mjculross/NTPclock-for-MWRS-CARC-REAST](https://github.com/mjculross/NTPclock-for-MWRS-CARC-REAST), click **Code > Download ZIP**, and extract it.
   - **Option B (Git):** Run:
     ```bash
     git clone https://github.com/mjculross/NTPclock-for-MWRS-CARC-REAST.git
     ```
2. **Rename the sketch folder (required by Arduino IDE):**
   - Arduino IDE requires the `.ino` file to be inside a folder with the **exact same name**.
   - Rename the extracted folder to **`NTP_Dual_Clock_MWRS_V4_x`** (or create a folder named `NTP_Dual_Clock_MWRS_V4_x` and copy `NTP_Dual_Clock_MWRS_V4_x.ino`, `tft_setup.h`, `UserSettings.h`, `Certificate.h`, and `partitions.csv` into it).

---

### Step 3: Install ESP32 Board Support in Arduino IDE

1. Open **Arduino IDE**.
2. Go to **File > Preferences** (on macOS: **Arduino IDE > Settings**).
3. Find **Additional Boards Manager URLs** and paste:
   ```text
   https://espressif.github.io/arduino-esp32/package_esp32_index.json
   ```
   *(If you already have other URLs there, separate them with a comma `,`.)*
4. Click **OK**.
5. Open **Tools > Board > Boards Manager...**.
6. Search for **`esp32`** and install **`esp32` by Espressif Systems** (tested with version **`3.3.10`**).
   - Reference docs: [Espressif Arduino-ESP32 Installation Guide](https://docs.espressif.com/projects/arduino-esp32/en/latest/installing.html)

---

### Step 4: Install Required Arduino Libraries

In Arduino IDE, open **Sketch > Include Library > Manage Libraries...** (or click the **Library Manager** icon in the left sidebar) and install each of the following libraries (tested versions shown):

| Library | Author | Tested Version | Link / Notes |
| --- | --- | --- | --- |
| **TFT_eSPI** | Bodmer | `2.5.43` | [GitHub](https://github.com/Bodmer/TFT_eSPI) — requires pin setup in Step 6 |
| **ezTime** | Rop Gonggrijp | `0.8.3` | [GitHub](https://github.com/ropg/ezTime) |
| **ArduinoJson** | Benoit Blanchon | `7.4.3` | [arduinojson.org](https://arduinojson.org/) |
| **Button2** | Lennart Hennigs | `2.7.0` | [GitHub](https://github.com/LennartHennigs/Button2) |
| **ESPAsyncWebServer** | ESP32Async | `3.12.1` | [GitHub](https://github.com/ESP32Async/ESPAsyncWebServer) |
| **AsyncTCP** | ESP32Async | `3.5.0` | [GitHub](https://github.com/ESP32Async/AsyncTCP) |
| **TinyGPSPlus** | Mikal Hart | `1.0.3` | [GitHub](https://github.com/mikalhart/TinyGPSPlus) |
| **SparkFun u-blox GNSS Arduino Library** | SparkFun Electronics | `2.2.29` | [GitHub](https://github.com/sparkfun/SparkFun_u-blox_GNSS_Arduino_Library) |
| **EspSoftwareSerial** | Dirk Kaar | `8.1.0` | [GitHub](https://github.com/plerup/espsoftwareserial) |
| **Preferences** | Volodymyr Shymanskyy | `2.4.0` | Install via Library Manager |
| **Adafruit BME280 Library** | Adafruit | `2.3.0` | [GitHub](https://github.com/adafruit/Adafruit_BME280_Library) — click **Install all** when prompted for dependencies |
| **Adafruit BMP280 Library** | Adafruit | `3.0.0` | [GitHub](https://github.com/adafruit/Adafruit_BMP280_Library) — click **Install all** when prompted for dependencies |

---

### Step 5: Select Your Hardware Target in `tft_setup.h`

Open [tft_setup.h](tft_setup.h) and uncomment **only** the line that matches your PCB and processor:

- **CARC v4 with ESP32-S3-mini:**
  ```cpp
  #define CARC_V4_ESP32S3_MINI
  //#define MWRS_ESP32S3_MINI
  ```
- **MWRS with ESP32-S3-mini:**
  ```cpp
  //#define CARC_V4_ESP32S3_MINI
  #define MWRS_ESP32S3_MINI
  ```
- **MWRS with ESP32-S2-mini (default):** Leave both lines commented out:
  ```cpp
  //#define CARC_V4_ESP32S3_MINI
  //#define MWRS_ESP32S3_MINI
  ```

---

### Step 6: Configure `TFT_eSPI` Display Pins

Because `TFT_eSPI` is compiled as a separate library, it reads its pin settings from `User_Setup.h` inside your Arduino libraries folder (typically `Documents/Arduino/libraries/TFT_eSPI/User_Setup.h`), **not** from the sketch's `tft_setup.h`.

Open `Documents/Arduino/libraries/TFT_eSPI/User_Setup.h` and make sure the active driver, SPI port, pins, color order, and fonts match your selected target in [tft_setup.h](tft_setup.h):

1. Ensure these common options are enabled:
   ```cpp
   #define ILI9341_DRIVER
   #define USE_HSPI_PORT
   #define CGRAM_OFFSET
   #define TFT_RGB_ORDER TFT_BRG
   #define TFT_WIDTH 240
   #define TFT_HEIGHT 320
   #define LOAD_GLCD
   #define LOAD_FONT2
   #define LOAD_FONT4
   #define LOAD_FONT6
   #define LOAD_FONT7
   #define LOAD_FONT8
   #define LOAD_GFXFF
   ```
2. Set the display pins for your target (and comment out any other `TFT_*` pin definitions in `User_Setup.h`):
   - **CARC v4 (`CARC_V4_ESP32S3_MINI`):**
     `TFT_MOSI 11`, `TFT_MISO 12`, `TFT_SCLK 13`, `TFT_RST 5`, `TFT_CS 6`, `TFT_DC 7`
   - **MWRS S3 (`MWRS_ESP32S3_MINI`):**
     `TFT_MOSI 11`, `TFT_MISO -1`, `TFT_SCLK 12`, `TFT_RST -1`, `TFT_CS 10`, `TFT_DC 18`
   - **MWRS S2 (default):**
     `TFT_MOSI 11`, `TFT_MISO -1`, `TFT_SCLK 7`, `TFT_RST -1`, `TFT_CS 12`, `TFT_DC 18`

---

### Step 7: (Optional) Customize Defaults in `UserSettings.h`

Before compiling, you can optionally edit [UserSettings.h](UserSettings.h) to set your defaults:
- `DEFAULT_TITLE` — Banner title (up to 8 characters, e.g. your callsign)
- `timeZones[]` — Add/remove POSIX timezone strings (1 to 32 entries; at least one must be `true`)
- `DEFAULT_QTH_ALTITUDE_IN_FEET` / `DEFAULT_QTH_ALTITUDE_IN_METERS`
- `DEFAULT_AP_NAME` — SoftAP SSID for web configuration (default: `"NTPCLOCK_AP"`)

*(Most settings can also be changed later through the clock's web interface.)*

---

### Step 8: Configure Board Settings in Arduino IDE

Open `NTP_Dual_Clock_MWRS_V4_x.ino` in Arduino IDE, then configure the **Tools** menu for your processor:

#### For ESP32-S3-mini (CARC v4 or MWRS S3)
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

#### For ESP32-S2-mini (MWRS S2)
- **Board:** `LOLIN S2 Mini` (under **Tools > Board > esp32**)
- **USB CDC On Boot:** `Enabled`
- **USB Firmware MSC On Boot:** `Disabled`
- **USB DFU On Boot:** `Disabled`
- **Partition Scheme:** `Huge App (3MB No OTA/1MB SPIFFS)`
- **Core Debug Level:** `None`
- **Erase All Flash Before Sketch Upload:** `Disabled`

> **Important:** Make sure the board selected in **Tools > Board** matches your `#define` target in `tft_setup.h`. Firmware built for the wrong processor will fail to upload; firmware built for the wrong PCB target will upload but the display will not work correctly.

---

### Step 9: Flash the Firmware to the ESP32-S3-mini (or S2-mini)

1. Connect the ESP32 module to your PC using a **USB-C data cable**.
2. **First-time upload only:** Put the ESP32 into bootloader/programming mode manually:
   1. Press and hold the **`0`** (or **`BOOT`**) button on the ESP32 module.
   2. Press and release the **`RST`** (or **`RESET`**) button.
   3. Release the **`0`** (or **`BOOT`**) button.
3. In Arduino IDE, select the serial port under **Tools > Port** (on Windows, open **Device Manager > Ports (COM & LPT)** to see which COM port appears when you plug in the board).
4. Click the **Upload** button (right arrow icon).
5. Wait for `Hard resetting via RTS pin...` / upload complete, then press **`RST`** once on the ESP32 module to boot the new firmware. *(Manual bootloader entry is not needed for future uploads.)*

---

## Step 10: First-Boot Setup on the Clock

1. Power on the clock. It creates a Wi-Fi Access Point named **`NTPCLOCK_AP`** by default.
2. Connect your phone or PC to **`NTPCLOCK_AP`** and open **`http://10.1.1.1`** in a web browser.
3. On the **NETWORK** tab, enter up to 6 Wi-Fi networks (SSID and password) and click **Save/Apply**.
4. On the **CONFIG** tab, set your banner title/callsign, active timezones, GPS mode, display preferences, and (for internet weather) your free OpenWeatherMap API key from [https://home.openweathermap.org/users/sign_up](https://home.openweathermap.org/users/sign_up).
5. Click **Save/Apply** to store your settings.
