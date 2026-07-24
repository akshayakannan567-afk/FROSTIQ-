#include <WiFi.h>
#include <WebServer.h>
#include <FirebaseESP32.h>
#include <PZEM004Tv30.h>
#include <WiFiManager.h>

// ============================================
// CONFIGURATION
// ============================================
#define DATABASE_URL    "https://YOUR-PROJECT.asia-southeast1.firebasedatabase.app"
#define DATABASE_SECRET "YOUR_DATABASE_SECRET"

// PIN DEFINITIONS
#define LM35_PIN          35
#define MQ135_PIN         34
#define REED_PIN          14
#define BUZZER_PIN        25
#define CONFIG_BUTTON_PIN 0   // Boot button for WiFi reset

// ============================================
// GLOBAL OBJECTS
// ============================================
PZEM004Tv30 pzem(Serial2, 16, 17);
WebServer server(80);
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

String DEVICE_ID;
String BASE_PATH;
unsigned long lastUpdateTime = 0;
unsigned long lastHistoryLogTime = 0;
unsigned long doorOpenStartTime = 0;
bool doorAlarmActive = false;

void handlePing() {
    bool isConnected = (WiFi.status() == WL_CONNECTED && WiFi.localIP().toString() != "0.0.0.0");
    String status = isConnected ? "connected" : "setup_mode";

    String json = "{\"status\":\"" + status + "\",\"device_id\":\"" + DEVICE_ID + "\"}";
    server.send(200, "application/json", json);
}

void setup() {
    Serial.begin(115200);
    delay(1500);

    // ============================================
    // Initialize WiFi first to get correct MAC
    // ============================================
    WiFi.mode(WIFI_STA);
    delay(100);

    // Now get the real MAC address
    DEVICE_ID = WiFi.macAddress();
    DEVICE_ID.replace(":", "");
    Serial.print("Device ID: ");
    Serial.println(DEVICE_ID);

    delay(300);

    // PIN SETUP
    pinMode(REED_PIN, INPUT_PULLUP);
    pinMode(BUZZER_PIN, OUTPUT);
    pinMode(CONFIG_BUTTON_PIN, INPUT_PULLUP);
    analogReadResolution(12);

    // ============================================
    // WiFiManager - Easy WiFi Setup
    // ============================================
    WiFiManager wm;

    // Reset WiFi if button is held on startup
    if (digitalRead(CONFIG_BUTTON_PIN) == LOW) {
        Serial.println("Resetting WiFi settings...");
        wm.resetSettings();
        delay(1000);
    }

    String portalName = "Frostiq_" + DEVICE_ID.substring(6);

    // This will block until user connects or timeout
    if (!wm.autoConnect(portalName.c_str())) {
        Serial.println("Failed to connect. Restarting...");
        ESP.restart();
    }

    Serial.println("WiFi Connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());

    // ============================================
    // Start Web Server for /ping (even when connected)
    // ============================================
    server.on("/ping", HTTP_GET, handlePing);
    server.begin();
    Serial.println("Web server started for status check");

    // ============================================
    // Firebase Setup
    // ============================================
    BASE_PATH = "/devices/" + DEVICE_ID;

    config.database_url = DATABASE_URL;
    config.signer.tokens.legacy_token = DATABASE_SECRET;
    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);

    // Initial status
    Firebase.setBool(fbdo, BASE_PATH + "/status/online", true);
    Firebase.setString(fbdo, BASE_PATH + "/metadata/model", "Frostiq-V1");
    Firebase.setString(fbdo, BASE_PATH + "/metadata/firmware", "2.0.0");

    Serial.println("Firebase Initialized!");
    Serial.println("Device ID: " + DEVICE_ID);
}

void loop() {
    server.handleClient();

    if (millis() - lastUpdateTime >= 3000) {
        lastUpdateTime = millis();

        // Read sensors
        int rawLM35 = analogRead(LM35_PIN);
        float voltageLM35 = (rawLM35 / 4095.0) * 3300.0;
        float tempC = voltageLM35 / 10.0;

        int gasLevel = analogRead(MQ135_PIN);

        float voltage = pzem.voltage();
        float current = pzem.current();
        float power = pzem.power();

        if (isnan(voltage)) voltage = 0;
        if (isnan(current)) current = 0;
        if (isnan(power)) power = 0;

        bool doorOpen = (digitalRead(REED_PIN) == HIGH);

        // ============================================
        // IMPROVED BUZZER LOGIC
        // ============================================
        if (doorOpen) {
            if (doorOpenStartTime == 0) {
                doorOpenStartTime = millis();
                Serial.println("Door opened - timer started");
            }

            if (millis() - doorOpenStartTime >= 30000) {
                digitalWrite(BUZZER_PIN, HIGH);
                doorAlarmActive = true;
                Serial.println("Buzzer ON - Door open > 30s");
            }
        } else {
            if (doorOpenStartTime != 0) {
                Serial.println("Door closed");
            }
            digitalWrite(BUZZER_PIN, LOW);
            doorOpenStartTime = 0;
            doorAlarmActive = false;
        }

        // Send to Firebase
        FirebaseJson json;
        json.set("telemetry/temp", tempC);
        json.set("telemetry/gas", gasLevel);
        json.set("telemetry/door_open", doorOpen);
        json.set("telemetry/voltage", voltage);
        json.set("telemetry/current", current);
        json.set("telemetry/power", power);
        json.set("telemetry/alarm", doorAlarmActive);
        json.set("status/online", true);
        json.set("status/last_seen", ".sv");

        Firebase.updateNode(fbdo, BASE_PATH, json);
    }

    // ============================================
    // LOG HISTORY EVERY 15 MINUTES
    // ============================================
    if (millis() - lastHistoryLogTime >= 900000) { // 15 mins
        lastHistoryLogTime = millis();
        Serial.println("Logging historical snapshot...");

        // Reuse sensor readings from loop or read fresh
        int rawLM35 = analogRead(LM35_PIN);
        float voltageLM35 = (rawLM35 / 4095.0) * 3300.0;
        float tempC = voltageLM35 / 10.0;
        float power = pzem.power();
        if (isnan(power)) power = 0;

        FirebaseJson historyJson;
        historyJson.set("temp", tempC);
        historyJson.set("power", power);
        historyJson.set("timestamp", ".sv"); // Firebase Server Value

        String historyPath = BASE_PATH + "/history";
        Firebase.pushJSON(fbdo, historyPath, historyJson);
    }
}