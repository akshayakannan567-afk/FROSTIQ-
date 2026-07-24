# FrostIQ - Smart Refrigerator Monitoring System

##  Project Structure
- `esp32/` - Arduino firmware for ESP32
- `manufacturing/` - QR code generator (Python CLI + Web Admin)
- `landing_page/` - Play Store redirect page for QR codes
- `mobile_app/` - Flutter mobile application
[README.md](README.md)
##  Quick Start

### 1. Setup Firebase
- Create project at https://console.firebase.google.com
- Enable Realtime Database (choose asia-southeast1)
- Enable Authentication (Email/Password)
- Copy Database URL and Database Secret

### 2. Flash ESP32
- Open `esp32/frostiq_firmware.ino` in Arduino IDE
- Install libraries: FirebaseESP32, PZEM004Tv30
- Update DATABASE_URL and DATABASE_SECRET
- Upload to ESP32

### 3. Generate QR Codes
```bash
cd manufacturing
pip install -r requirements.txt
python frostiq_qr_generator.py
```

### 4. Deploy Landing Page
```bash
firebase init hosting
# Point to landing_page folder
firebase deploy --only hosting
```

### 5. Run Mobile App
```bash
cd mobile_app
flutter pub get
flutterfire configure
flutter run
```

##  User Flow
1. Customer scans QR sticker ? Opens app (or downloads it)
2. App shows WiFi setup screen
3. Customer joins "Frostiq_XXXX" hotspot
4. Enters home WiFi credentials
5. Names their device
6. Live dashboard opens with sensor data

##  Notifications
- Door open > 30s ? Critical alert
- Temperature > 10�C ? Critical alert
- Gas level > 700 ? Warning
- Power > 300W ? Warning

## ? Theme
- Dark theme with cyan (#00E5FF) accents
- Cards: #141824
- Background: #0A0E1A
