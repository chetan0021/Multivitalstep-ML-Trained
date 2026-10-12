#include <Arduino.h>
// #include <LiquidCrystal_I2C.h> // Removed LCD Library
#include "HX711.h"
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1305.h> // Changed to SSD1305 for your specific OLED
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <SD.h>
#include <SPI.h>
#include <Preferences.h>

// --- BLE ---
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// --- OLED CONFIGURATION ---
// Using 128x32 OLED via I2C
// NOTE: I2C on ESP32-S3 defaults to SDA=GPIO8, SCL=GPIO9 in the Arduino
// core - left unassigned/untouched here so display.begin() just works.
#define OLED_RESET 4
Adafruit_SSD1305 display(128, 32, &Wire, OLED_RESET);

// HX711 circuit wiring
#define I2C_ADDR 0x27 // (Unused now)
#define LCD_COLUMNS 16 // (Unused now)
#define LCD_ROWS 2     // (Unused now)
#define L1 5
//#define L2 26
#define L3 6

const int LOADCELL_DOUT_PIN = 7;
const int LOADCELL_SCK_PIN = 15;

HX711 scale;
float reading;
float maxReading;
unsigned long lastReadTime;
const unsigned long readInterval = 100; // Interval to read the weight
const unsigned long stabilizationTime = 700; // Time to wait for weight stabilization
float previousReading = 0.0;
unsigned long weightStableStartTime = 0;

// Calibration Factor
#define CALIBRATION_FACTOR 10300

// ============================================================
//  WI-FI PROVISIONING (replaces hardcoded ssid/password)
// ============================================================
// Credentials are no longer hardcoded. They are either:
//   1) Loaded from on-chip NVS flash (via the Preferences library,
//      from a previous successful provisioning), or
//   2) Received live over BLE from the companion app during a
//      provisioning session, then saved to NVS for next boot.
// No SD file is used for this — SD is still used elsewhere for
// deviceID.txt / devicecode.txt, unrelated to Wi-Fi.
//
// BLE provisioning protocol (for the app team):
//   Service UUID        : 6b1a0001-4b4a-4a3f-9f0a-3a2b6c8e1a10
//   Char WIFI_SCAN       : 6b1a0002-4b4a-4a3f-9f0a-3a2b6c8e1a10
//     - WRITE  : any value triggers a Wi-Fi scan
//     - NOTIFY : one JSON object per notification, one per found
//                network: {"ssid":"...","rssi":-55,"secure":true}
//                followed by a final {"done":true,"count":N}
//   Char WIFI_CREDS       : 6b1a0003-4b4a-4a3f-9f0a-3a2b6c8e1a10
//     - WRITE  : {"ssid":"...","password":"..."}  (password may be
//                omitted/empty for open networks). Works the same
//                whether the SSID came from the scanned list or was
//                typed manually in the app ("Enter Wi-Fi manually").
//   Char WIFI_STATUS      : 6b1a0004-4b4a-4a3f-9f0a-3a2b6c8e1a10
//     - NOTIFY : "SCANNING" | "SCAN_COMPLETE" | "CONNECTING" |
//                "CONNECTED:<ip>" | "FAILED:<reason>" |
//                "AWAITING_CREDENTIALS"
// ============================================================

#define BLE_SERVICE_UUID        "6b1a0001-4b4a-4a3f-9f0a-3a2b6c8e1a10"
#define BLE_WIFI_SCAN_UUID      "6b1a0002-4b4a-4a3f-9f0a-3a2b6c8e1a10"
#define BLE_WIFI_CREDS_UUID     "6b1a0003-4b4a-4a3f-9f0a-3a2b6c8e1a10"
#define BLE_WIFI_STATUS_UUID    "6b1a0004-4b4a-4a3f-9f0a-3a2b6c8e1a10"

Preferences wifiPrefs;
#define WIFI_PREFS_NAMESPACE "wificreds"

struct WiFiCredentials {
  bool valid;
  String ssid;
  String password;
};

BLEServer* bleServer = nullptr;
BLECharacteristic* wifiScanChar = nullptr;
BLECharacteristic* wifiCredsChar = nullptr;
BLECharacteristic* wifiStatusChar = nullptr;

volatile bool bleClientConnected = false;
volatile bool provisioningActive = false;
volatile bool wifiCredsReceived = false;
String pendingSSID = "";
String pendingPassword = "";
String bleDeviceName = "PalmPressure";

// Forward declarations (BLE / Wi-Fi provisioning)
void startBLEProvisioning();
void runBLEProvisioningLoop();
void sendBLEStatus(const String &status);
void sendWiFiScanResults();
bool connectToWiFi(const String &ssid, const String &password, unsigned long timeoutMs);
WiFiCredentials readWiFiCredentials();
void writeWiFiCredentials(const String &ssid, const String &password);
void deleteWiFiCredentials();

// API Endpoints
String getApiEndpoint = "https://backend.sp4ameya.com/api/queue/device/";
String postApiEndpoint = "https://backend.sp4ameya.com/api/test/";
String deleteApiEndpoint = "https://backend.sp4ameya.com/api/queue/device/";

// Buttons
#define BUTTON_START_PIN 16
#define BUTTON_PAIR_PIN 17

const int buzzerPin = 18;

// Musical Notes (frequencies in Hz)
#define NOTE_G5  784
#define NOTE_A5  880
#define NOTE_B5  988
#define NOTE_C5  523
#define NOTE_E5  659
#define NOTE_A4  440
#define NOTE_E6 1319
#define NOTE_G6 1568
#define NOTE_B6 1976
#define NOTE_D6 1175 
#define NOTE_F5 698 
#define NOTE_F6 1397 
#define NOTE_C6 1047 
#define NOTE_F4 349   // F4 frequency in Hertz
#define NOTE_D4 294   // D4 frequency in Hertz


// SD Card settings
// These match the ESP32-S3's commonly broken-out default SPI pins on
// most DevKitC-1 style boards (CS=10, MOSI=11, SCK=12, MISO=13).
// Double-check against your specific board's silkscreen before wiring.
#define SD_CS_PIN 10
#define SD_SCK_PIN  12
#define SD_MISO_PIN 13
#define SD_MOSI_PIN 11
SPIClass hspi(HSPI);

// State variables
bool weightApplied = false;
bool trialStarted = false;

// Trial data
float trial1 = 0.0, trial2 = 0.0, trial3 = 0.0;

// Received data
String posture;
String hand;
int userId;
int deviceId;
int assessmentId;

// File names on SD card
const char* deviceCodeFile = "/devicecode.txt";
const char* deviceIDFile = "/deviceID.txt";

// Function declarations
String readDeviceCode();
String readDeviceID();
void writeDeviceID(String id);
void deleteDeviceID();
bool fetchDataFromAPI();
void postResultsToAPI();
void deleteAssessment();
float runTrial(const char* trialLabel);
void printResults();
void displayWeight(float weight);
void blinkMaxWeight();
void playButtonBeep();
void playDevicePairedTone();
void playDeviceUnpairedTone();
void playEndTone();
void playNoAssessmentTone();
void playStartTrialTone();
void playTakeHandTone();

// ============================================================
//  BLE CALLBACKS
// ============================================================
class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override {
    bleClientConnected = true;
    Serial.println("[BLE] Client connected");
  }
  void onDisconnect(BLEServer* pServer) override {
    bleClientConnected = false;
    Serial.println("[BLE] Client disconnected");
    if (provisioningActive) {
      Serial.println("[BLE] Provisioning still active, resuming advertising...");
      delay(300);
      pServer->getAdvertising()->start();
      Serial.println("[BLE] Advertising resumed");
    }
  }
};

class ScanCharCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pChar) override {
    Serial.println("[BLE] Wi-Fi scan requested by app");
    sendWiFiScanResults();
  }
};

class CredsCharCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pChar) override {
    String value = pChar->getValue();
    Serial.println("[BLE] Credentials write received, raw length: " + String(value.length()));
    if (value.length() == 0) {
      Serial.println("[BLE] Empty write, ignoring");
      return;
    }

    StaticJsonDocument<256> doc;
    DeserializationError err = deserializeJson(doc, value);
    if (err) {
      Serial.println("[BLE] JSON parse failed: " + String(err.c_str()));
      sendBLEStatus("FAILED:BAD_JSON");
      return;
    }
    if (!doc.containsKey("ssid") || String((const char*)doc["ssid"]).isEmpty()) {
      Serial.println("[BLE] No SSID present in payload");
      sendBLEStatus("FAILED:NO_SSID");
      return;
    }

    pendingSSID = String((const char*)doc["ssid"]);
    pendingPassword = doc.containsKey("password") ? String((const char*)doc["password"]) : "";
    Serial.println("[BLE] Parsed SSID: " + pendingSSID + " | Password length: " + String(pendingPassword.length()));
    wifiCredsReceived = true; // picked up by runBLEProvisioningLoop()
  }
};

// ============================================================
//  WI-FI PROVISIONING HELPERS
// ============================================================

void sendBLEStatus(const String &status) {
  Serial.println("[BLE STATUS] " + status);
  if (wifiStatusChar) {
    wifiStatusChar->setValue(status.c_str());
    wifiStatusChar->notify();
  }
}

void sendWiFiScanResults() {
  Serial.println("[WiFi] Starting network scan...");
  sendBLEStatus("SCANNING");

  int n = WiFi.scanNetworks();
  Serial.println("[WiFi] Scan complete, networks found: " + String(n));

  for (int i = 0; i < n; i++) {
    StaticJsonDocument<192> doc;
    doc["ssid"] = WiFi.SSID(i);
    doc["rssi"] = WiFi.RSSI(i);
    doc["secure"] = (WiFi.encryptionType(i) != WIFI_AUTH_OPEN);

    String out;
    serializeJson(doc, out);
    Serial.println("[WiFi] (" + String(i + 1) + "/" + String(n) + ") " + out);

    if (wifiScanChar) {
      wifiScanChar->setValue(out.c_str());
      wifiScanChar->notify();
    }
    delay(30); // give the BLE stack breathing room between notifications
  }

  StaticJsonDocument<64> doneDoc;
  doneDoc["done"] = true;
  doneDoc["count"] = n;
  String doneOut;
  serializeJson(doneDoc, doneOut);
  if (wifiScanChar) {
    wifiScanChar->setValue(doneOut.c_str());
    wifiScanChar->notify();
  }

  WiFi.scanDelete();
  Serial.println("[WiFi] Scan results sent over BLE");
  sendBLEStatus("SCAN_COMPLETE");
}

bool connectToWiFi(const String &ssid, const String &password, unsigned long timeoutMs) {
  Serial.println("[WiFi] Attempting connection to SSID: \"" + ssid + "\" (timeout " + String(timeoutMs) + "ms)");
  WiFi.disconnect(true, true);
  delay(200);
  WiFi.mode(WIFI_STA);

  if (password.length() > 0) {
    WiFi.begin(ssid.c_str(), password.c_str());
  } else {
    Serial.println("[WiFi] No password supplied, treating as open network");
    WiFi.begin(ssid.c_str()); // open network
  }

  unsigned long start = millis();
  bool ledState = false;
  while (WiFi.status() != WL_CONNECTED && (millis() - start) < timeoutMs) {
    delay(250);
    ledState = !ledState;
    digitalWrite(L1, ledState ? HIGH : LOW);
    Serial.print(".");
  }
  digitalWrite(L1, LOW);
  Serial.println();

  bool connected = WiFi.status() == WL_CONNECTED;
  if (connected) {
    Serial.println("[WiFi] Connected! IP address: " + WiFi.localIP().toString() + " | RSSI: " + String(WiFi.RSSI()) + " dBm");
  } else {
    Serial.println("[WiFi] Connection FAILED after timeout. WiFi.status() = " + String(WiFi.status()));
  }

  return connected;
}

WiFiCredentials readWiFiCredentials() {
  WiFiCredentials creds;
  creds.valid = false;

  wifiPrefs.begin(WIFI_PREFS_NAMESPACE, true); // read-only
  String ssid = wifiPrefs.getString("ssid", "");
  String password = wifiPrefs.getString("pass", "");
  wifiPrefs.end();

  if (ssid.length() > 0) {
    creds.valid = true;
    creds.ssid = ssid;
    creds.password = password;
    Serial.println("[NVS] Found saved credentials for SSID: \"" + ssid + "\"");
  } else {
    Serial.println("[NVS] No saved Wi-Fi credentials found");
  }
  return creds;
}

void writeWiFiCredentials(const String &ssid, const String &password) {
  wifiPrefs.begin(WIFI_PREFS_NAMESPACE, false); // read-write
  wifiPrefs.putString("ssid", ssid);
  wifiPrefs.putString("pass", password);
  wifiPrefs.end();
  Serial.println("[NVS] Wi-Fi credentials saved for SSID: \"" + ssid + "\"");
}

void deleteWiFiCredentials() {
  wifiPrefs.begin(WIFI_PREFS_NAMESPACE, false);
  wifiPrefs.clear();
  wifiPrefs.end();
  Serial.println("[NVS] Saved Wi-Fi credentials cleared");
}

void startBLEProvisioning() {
  provisioningActive = true;
  Serial.println("========================================");
  Serial.println("[BLE] Starting provisioning mode...");

  uint64_t chipId = ESP.getEfuseMac();
  char suffix[5];
  snprintf(suffix, sizeof(suffix), "%04X", (uint16_t)(chipId & 0xFFFF));
  bleDeviceName = "PalmPressure-" + String(suffix);

  BLEDevice::init(bleDeviceName.c_str());
  bleServer = BLEDevice::createServer();
  bleServer->setCallbacks(new ServerCallbacks());

  BLEService* service = bleServer->createService(BLE_SERVICE_UUID);

  wifiScanChar = service->createCharacteristic(
    BLE_WIFI_SCAN_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_WRITE
  );
  wifiScanChar->addDescriptor(new BLE2902());
  wifiScanChar->setCallbacks(new ScanCharCallbacks());

  wifiCredsChar = service->createCharacteristic(
    BLE_WIFI_CREDS_UUID,
    BLECharacteristic::PROPERTY_WRITE
  );
  wifiCredsChar->setCallbacks(new CredsCharCallbacks());

  wifiStatusChar = service->createCharacteristic(
    BLE_WIFI_STATUS_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
  );
  wifiStatusChar->addDescriptor(new BLE2902());

  service->start();
  Serial.println("[BLE] GATT service started, UUID: " BLE_SERVICE_UUID);

  BLEAdvertising* adv = BLEDevice::getAdvertising();
  adv->addServiceUUID(BLE_SERVICE_UUID);
  adv->setScanResponse(true);
  adv->setMinPreferred(0x06);
  BLEDevice::startAdvertising();

  Serial.println("[BLE] Advertising started as: \"" + bleDeviceName + "\"");
  Serial.println("[BLE] Waiting for app to connect and send Wi-Fi credentials...");
  Serial.println("========================================");

  display.clearDisplay();
  display.setCursor(0, 0);
  display.println("BLE Setup Mode");
  display.setCursor(0, 16);
  display.println(bleDeviceName);
  display.display();

  sendBLEStatus("AWAITING_CREDENTIALS");
}

// Blocks until Wi-Fi is connected and credentials are saved.
void runBLEProvisioningLoop() {
  unsigned long lastHeartbeat = 0;
  while (true) {
    // Periodic heartbeat so the serial monitor shows we're alive and waiting
    if (millis() - lastHeartbeat > 5000) {
      lastHeartbeat = millis();
      Serial.println("[BLE] Still waiting... client connected: " + String(bleClientConnected ? "yes" : "no"));
    }

    if (wifiCredsReceived) {
      wifiCredsReceived = false;
      Serial.println("[BLE] Credentials received, attempting connection to \"" + pendingSSID + "\"");

      display.clearDisplay();
      display.setCursor(0, 0);
      display.println("Connecting to:");
      display.setCursor(0, 16);
      display.println(pendingSSID);
      display.display();

      sendBLEStatus("CONNECTING");
      bool ok = connectToWiFi(pendingSSID, pendingPassword, 15000);

      if (ok) {
        writeWiFiCredentials(pendingSSID, pendingPassword);
        String ip = WiFi.localIP().toString();
        Serial.println("[BLE] Provisioning succeeded, IP: " + ip);
        sendBLEStatus("CONNECTED:" + ip);

        display.clearDisplay();
        display.setCursor(0, 0);
        display.println("WiFi Connected");
        display.setCursor(0, 16);
        display.println(ip);
        display.display();

        digitalWrite(L3, HIGH); delay(300); digitalWrite(L3, LOW); delay(300);
        digitalWrite(L3, HIGH); delay(300); digitalWrite(L3, LOW); delay(300);

        delay(1500);
        provisioningActive = false;
        Serial.println("[BLE] Exiting provisioning mode");
        return; // hand control back to setup()
      } else {
        Serial.println("[BLE] Connection attempt failed, staying in provisioning mode for retry");
        sendBLEStatus("FAILED:CONNECT_TIMEOUT");
        display.clearDisplay();
        display.setCursor(0, 0);
        display.println("Connect Failed");
        display.setCursor(0, 16);
        display.println("Retry in app");
        display.display();
        // stays in provisioning mode, waiting for another WIFI_CREDS write
      }
    }
    delay(50);
  }
}

void setup() {
  Serial.begin(115200);

  // Core GPIO setup needed before anything else (LEDs, buttons, buzzer) —
  // these are needed early for the WiFi/BLE provisioning step below.
  pinMode(L1, OUTPUT);
  //pinMode(L2, OUTPUT);
  pinMode(L3, OUTPUT);
  pinMode(BUTTON_START_PIN, INPUT);
  pinMode(BUTTON_PAIR_PIN, INPUT);
  pinMode(buzzerPin, OUTPUT);

  // --- OLED INIT --- (needed early to show connection/provisioning status)
  // Try 0x3C first, if that fails, the library usually handles it or try 0x3D
  if (!display.begin(0x3C)) {
    Serial.println("SSD1305 allocation failed");
    // Continue anyway to not block logic, but screen wont work
  }
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.setCursor(11, 14);
  display.println("Initializing...");
  display.display();
  // ----------------

  // ============================================================
  //  WI-FI CONNECT (BLE-provisioned, replaces hardcoded ssid/password)
  //  This runs FIRST, before SD card / HX711 / any other peripheral
  //  init, so connection logic can be tested standalone.
  // ============================================================
  // Hold BOTH buttons at power-on to wipe saved Wi-Fi credentials and
  // force a fresh BLE provisioning session (e.g. moving the device to
  // a new site/network).
  Serial.println("========================================");
  Serial.println("[SETUP] Checking Wi-Fi connection state...");
  bool forceProvision = (digitalRead(BUTTON_START_PIN) == HIGH && digitalRead(BUTTON_PAIR_PIN) == HIGH);

  bool wifiConnected = false;

  if (!forceProvision) {
    Serial.println("[SETUP] Looking for saved Wi-Fi credentials in NVS...");
    WiFiCredentials creds = readWiFiCredentials();
    if (creds.valid) {
      display.clearDisplay();
      display.setCursor(0, 0);
      display.println("Connecting to");
      display.setCursor(0, 16);
      display.println(creds.ssid);
      display.display();

      wifiConnected = connectToWiFi(creds.ssid, creds.password, 15000);
      if (!wifiConnected) {
        Serial.println("[SETUP] Saved Wi-Fi credentials failed, falling back to BLE provisioning");
      }
    } else {
      Serial.println("[SETUP] No saved credentials, going straight to BLE provisioning");
    }
  } else {
    Serial.println("[SETUP] Force-provision requested (both buttons held at boot)");
    deleteWiFiCredentials();
  }

  if (!wifiConnected) {
    startBLEProvisioning();
    runBLEProvisioningLoop(); // blocks here until Wi-Fi is connected
  }

  Serial.println("[SETUP] Wi-Fi connected! IP: " + WiFi.localIP().toString());
  Serial.println("========================================");
  display.clearDisplay();
  display.setCursor(0, 0);
  display.println("WiFi Connected");
  display.display();

  digitalWrite(L3, HIGH);   
  delay(300);                       
  digitalWrite(L3, LOW);    
  delay(300);   
  digitalWrite(L3, HIGH);   
  delay(300);                       
  digitalWrite(L3, LOW);    
  delay(300);   
  digitalWrite(L3, HIGH);   
  delay(300);                       
  digitalWrite(L3, LOW);    
  delay(300);   

  display.clearDisplay();
  display.display();

  tone(buzzerPin, NOTE_C5, 100);
  delay(200);
  tone(buzzerPin, NOTE_A5, 100);
  delay(200);
  tone(buzzerPin, NOTE_E5, 100);
  delay(200);
  tone(buzzerPin, NOTE_B5, 100);
  delay(200);
  tone(buzzerPin, NOTE_A4, 100);
  delay(200);
  tone(buzzerPin, NOTE_G5, 100);
  digitalWrite(L3, LOW);
  delay(300);

  // ============================================================
  //  SD CARD + HX711 INIT — runs AFTER Wi-Fi is confirmed connected.
  //  (Not physically wired up yet during this connection-logic test —
  //  code is kept in place and will run once hardware is attached.)
  // ============================================================
  Serial.println("[SETUP] Initializing SD card...");
  hspi.begin(SD_SCK_PIN, SD_MISO_PIN, SD_MOSI_PIN, SD_CS_PIN);

  if (!SD.begin(SD_CS_PIN, hspi)) {
    Serial.println("SD Card failed or not present");
    display.clearDisplay();
    display.setCursor(0, 0);
    display.println("SD Card Error");
    display.display();
    while (1) { delay(1000); }   // HARD STOP — SD is critical for your app (delay feeds the watchdog so this doesn't trigger a reboot loop)
  }

  Serial.println("SD Card initialized");

  // Initialize HX711
  Serial.println("Initializing the scale");
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
  scale.set_scale(CALIBRATION_FACTOR);
  scale.tare();
      digitalWrite(L1, HIGH);   
    delay(500);                       
    digitalWrite(L1, LOW);    
    delay(500);   
    digitalWrite(L3, HIGH);   
    delay(500);                       
    digitalWrite(L3, LOW);    
    delay(500);
}

void loop() {
  // Handle PAIR button press
  if (digitalRead(BUTTON_START_PIN) == HIGH || digitalRead(BUTTON_PAIR_PIN) == HIGH) {
    playButtonBeep();
  }
  
if (digitalRead(BUTTON_START_PIN) == LOW && digitalRead(BUTTON_PAIR_PIN) == LOW) {
        display.clearDisplay();
        display.setCursor(12, 14);
        display.println("Start Measuring");
        display.display();

  return;
}
if (digitalRead(BUTTON_PAIR_PIN) == HIGH) {
  Serial.println("PAIR button pressed");
  String deviceID = readDeviceID();
  Serial.println("Device ID read: " + deviceID);
  
  if (deviceID.isEmpty()) {
    Serial.println("Device ID is empty, attempting to read device code");
    String deviceCode = readDeviceCode();

      if (deviceCode.isEmpty()) {
        display.clearDisplay();
        display.setCursor(0, 0);
        display.println("No CODE in SD");
        display.display();

        playButtonBeep();
        delay(2000);
        return;
      }
      HTTPClient http;
      http.begin("https://backend.sp4ameya.com/api/device/fetch-id");
      http.addHeader("Content-Type", "application/json");

      StaticJsonDocument<128> doc;
      doc["code"] = deviceCode;
      String requestBody;
      serializeJson(doc, requestBody);

      int httpResponseCode = http.POST(requestBody);
      if (httpResponseCode > 0) {
        String response = http.getString();
        Serial.println(response);

        StaticJsonDocument<512> responseDoc;
        deserializeJson(responseDoc, response);

        String newDeviceID = responseDoc["id"].as<String>();
        writeDeviceID(newDeviceID);
        display.clearDisplay();
        display.setCursor(12, 14);
        display.println("Device Paired");
        display.display();
            digitalWrite(L3, HIGH);   
            delay(200);                       
        playDevicePairedTone();
         digitalWrite(L3, LOW);  
      } else {
        Serial.printf("Error fetching device ID. HTTP code: %d\n", httpResponseCode);
      }
      http.end();
    } else {
        deleteDeviceID();
        display.clearDisplay();
        display.setCursor(12, 14);
        display.println("Device Unpaired");
        display.display();
            digitalWrite(L1, HIGH);   
            delay(200);   
         playDeviceUnpairedTone();
      digitalWrite(L1, LOW); 
    }
    delay(2000);
    return;
  }


  // Handle TEST button press
  if (digitalRead(BUTTON_START_PIN) == HIGH) {
    String deviceID = readDeviceID();
    if (deviceID.isEmpty()) {
        display.clearDisplay();
        display.setCursor(12, 0);
        display.println("Device not");
        display.setCursor(4 * 6, 16);
        display.println("paired");
        display.display();

      playDeviceUnpairedTone();
      delay(2000);
      display.clearDisplay();
      display.display();
      return;
    }
    
    getApiEndpoint = "https://backend.sp4ameya.com/api/queue/device/" + deviceID;
    deleteApiEndpoint = "https://backend.sp4ameya.com/api/queue/device/" + deviceID;

    if (fetchDataFromAPI()) {
      trialStarted = true;
      digitalWrite(L3, HIGH); 
      trial1 = runTrial("Trial 1");
       digitalWrite(L3, LOW); 
       delay(500);
       digitalWrite(L3, HIGH); 

      trial2 = runTrial("Trial 2");
      digitalWrite(L3, LOW); 
       delay(500);
       digitalWrite(L3, HIGH);
      trial3 = runTrial("Trial 3");
      digitalWrite(L3, LOW); 
       delay(500);
       digitalWrite(L3, HIGH);

      printResults();
      postResultsToAPI();
      playEndTone();
      deleteAssessment();

      trialStarted = false;
     digitalWrite(L3, HIGH);   
    delay(200);                       
    digitalWrite(L3, LOW);    
    delay(200);   
    digitalWrite(L3, HIGH);   
    delay(200);                       
    digitalWrite(L3, LOW);
      display.clearDisplay();
      display.display();

         digitalWrite(L3, HIGH);   
    delay(200);                       
    digitalWrite(L3, LOW);    
    delay(200);   
    digitalWrite(L3, HIGH);   
    delay(200);                       
    digitalWrite(L3, LOW);
    display.clearDisplay();
    display.display();
    } else {
        display.clearDisplay();
        display.setCursor(0, 0);
        display.println("No Assessment");
        display.display();

        digitalWrite(L1, HIGH);
        delay(300);
      playNoAssessmentTone();
      delay(3000);
      digitalWrite(L1, LOW);
    }
  }
}

// Trial function to capture weight
float runTrial(const char* trialLabel) {
  maxReading = 0;
  weightApplied = false;
        display.clearDisplay();
        display.setCursor(0, 0);
        display.println(trialLabel);
         display.setCursor(2 * 6, 16);
        display.println(" Apply weight");
        display.display();

 playStartTrialTone();
  while (!weightApplied) {
    reading = scale.get_units() * 0.454; // Convert lbs to kg
    if (reading > 0.1) {
      weightApplied = true;
      previousReading = reading;
      lastReadTime = millis();
        display.clearDisplay();
        displayWeight(reading);      
    }
  }

  while (weightApplied) {
    if (millis() - lastReadTime >= readInterval) {
      reading = scale.get_units() * 0.454;

      if (reading > maxReading) {
        maxReading = reading;
        weightStableStartTime = millis();
      }
        
      displayWeight(reading);
      lastReadTime = millis();

      if (abs(reading - previousReading) < 0.05) {
        if (millis() - weightStableStartTime > stabilizationTime) {
          weightApplied = false;
        }
      } else {
        weightStableStartTime = millis();
      }

      previousReading = reading;
    }
  }
 playTakeHandTone();
  display.clearDisplay();

        display.setCursor(3 * 6, 0);
        display.println(" Take Hand ");
        display.display();
  delay(3000);

  blinkMaxWeight();
  return maxReading;
}


void displayWeight(float weight) {
        display.clearDisplay();
        display.setCursor(0, 0);
        display.println("Weight: ");
        
        display.setCursor(7 * 6, 16);
        display.print(weight, 1);  
        display.setCursor(12 * 6, 16);
        display.print("KG");
        
        display.display();
}

void blinkMaxWeight() {
  for (int i = 0; i < 2; i++) {
    display.clearDisplay();
    display.display();
    displayWeight(maxReading);
    digitalWrite(L3, HIGH);
    delay(300);
    digitalWrite(L3, LOW);
    delay(300);
  }
}


void printResults() {
  Serial.println("{");
  Serial.print("\t\"userId\": ");
  Serial.print(userId);
  Serial.println(",");

  Serial.print("\t\"deviceId\": ");
  Serial.print(deviceId);
  Serial.println(",");

  Serial.print("\t\"assessmentId\": ");
  Serial.print(assessmentId);
  Serial.println(",");

  Serial.print("\t\"posture\": \"");
  Serial.print(posture);
  Serial.println("\",");

  Serial.print("\t\"hand\": \"");
  Serial.print(hand);
  Serial.println("\",");

  Serial.print("\t\"trial1\": ");
  Serial.print(trial1, 1);
  Serial.println(",");

  Serial.print("\t\"trial2\": ");
  Serial.print(trial2, 1);
  Serial.println(",");

  Serial.print("\t\"trial3\": ");
  Serial.print(trial3, 1);
  Serial.println("\n}");
}

void playButtonBeep() {
  tone(buzzerPin, NOTE_C5, 100);
  delay(200);
  noTone(buzzerPin);
}

void playTakeHandTone() {
  tone(buzzerPin, NOTE_C6, 75);
  delay(200);
  tone(buzzerPin, NOTE_E6, 50);
  delay(250);
  tone(buzzerPin, NOTE_A5, 100);
}

void playStartTrialTone() {
  tone(buzzerPin, NOTE_C5, 75);
  delay(100);
  tone(buzzerPin, NOTE_E5, 75);
  delay(100);
  tone(buzzerPin, NOTE_G5, 100);
  delay(150);
}

void playNoAssessmentTone() {
  tone(buzzerPin, NOTE_A4, 150);
  delay(200);
  tone(buzzerPin, NOTE_F4, 150);
  delay(250);
  tone(buzzerPin, NOTE_D4, 100);
  delay(300);
}

void playDevicePairedTone() {
  tone(buzzerPin, NOTE_C5, 100);
  delay(150);
  tone(buzzerPin, NOTE_E5, 100);
  delay(150);
  tone(buzzerPin, NOTE_G5, 150);
  delay(200);
  tone(buzzerPin, NOTE_C6, 200);
  delay(300);
}

void playDeviceUnpairedTone() {
  tone(buzzerPin, NOTE_C6, 100);
  delay(150);
  tone(buzzerPin, NOTE_G5, 100);
  delay(150);
  tone(buzzerPin, NOTE_E5, 150);
  delay(200);
  tone(buzzerPin, NOTE_C5, 200);
  delay(300);
}

void playEndTone() {
  tone(buzzerPin, NOTE_E6, 50);
  delay(150);
  tone(buzzerPin, NOTE_G6, 50);
  delay(150);
  tone(buzzerPin, NOTE_B5, 75);
  delay(200);
  tone(buzzerPin, NOTE_D6, 50);
  delay(150);
  tone(buzzerPin, NOTE_F5, 100);
  delay(200);
  tone(buzzerPin, NOTE_A5, 100);
  delay(150);
  tone(buzzerPin, NOTE_C6, 150);
  delay(350);
}

// API Call Functions
bool fetchDataFromAPI() {
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("WiFi connected, making GET request...");
    Serial.println("API Endpoint: " + getApiEndpoint);

    HTTPClient http;
    http.begin(getApiEndpoint);
    http.setTimeout(10000);

    int httpResponseCode = http.GET();

    Serial.print("HTTP Response Code: ");
    Serial.println(httpResponseCode);

    if (httpResponseCode == HTTP_CODE_OK) {
      String payload = http.getString();
      Serial.println("Received payload:");
      Serial.println(payload);

      StaticJsonDocument<512> doc;
      DeserializationError error = deserializeJson(doc, payload);

      if (!error) {
        JsonArray array = doc.as<JsonArray>();
        Serial.print("Array size: ");
        Serial.println(array.size());

        if (array.size() > 0) {
          JsonObject obj = array[0];
          posture = obj["posture"].as<String>();
          hand = obj["hand"].as<String>();
          userId = obj["userId"];
          deviceId = obj["deviceId"];
          assessmentId = obj["assessmentId"];
          Serial.println("Data fetched successfully");
          return true;
        } else {
          Serial.println("No assessment data in the array.");
        }
      } else {
        Serial.print("Deserialization failed: ");
        Serial.println(error.c_str());
      }
    } else {
      Serial.println("Failed to fetch data from API.");
    }
    http.end();
  }
  return false;
}


void postResultsToAPI() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(postApiEndpoint);
    http.addHeader("Content-Type", "application/json");

    StaticJsonDocument<512> doc;
    doc["userId"] = userId;
    doc["deviceId"] = deviceId;
    doc["assestmentId"] = assessmentId;
    doc["posture"] = posture;
    doc["hand"] = hand;
    doc["trial1"] = trial1;
    doc["trial2"] = trial2;
    doc["trial3"] = trial3;

    String requestBody;
    serializeJson(doc, requestBody);

    int httpResponseCode = http.POST(requestBody);
    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("POST Response:");
      Serial.println(response);
    } else {
      Serial.println("Error in POST request");
    }
    http.end();
  }
        digitalWrite(L1, HIGH);
        delay(100);
        digitalWrite(L1, LOW);
        delay(100);
        digitalWrite(L3, HIGH);
        delay(100);
        digitalWrite(L3, LOW);
        delay(100);
        digitalWrite(L1, HIGH);
        delay(100);
        digitalWrite(L1, LOW);
        delay(100);
        digitalWrite(L3, HIGH);
        delay(100);
        digitalWrite(L3, LOW);
        delay(100);
}

void deleteAssessment() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(deleteApiEndpoint);
    int httpResponseCode = http.sendRequest("DELETE");

    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("Deleted assessment:");
      Serial.println(response);
    } else {
      Serial.println("Error deleting assessment");
    }
    http.end();
  }
}

// SD card handling functions
String readDeviceCode() {
  if (SD.exists(deviceCodeFile)) {
    File file = SD.open(deviceCodeFile);
    if (file) {
      String code = file.readString();
      file.close();
      return code;
    }
  }
  return "";
}

String readDeviceID() {
  if (SD.exists(deviceIDFile)) {
    File file = SD.open(deviceIDFile);
    if (file) {
      String id = file.readString();
      file.close();
      id.trim(); 
      return id;
    }
  }
  return "";
}

void writeDeviceID(String id) {
  File file = SD.open(deviceIDFile, FILE_WRITE);
  if (file) {
    file.println(id);
    file.close();
  }
}

void deleteDeviceID() {
  SD.remove(deviceIDFile);                         
}
