<img width="1920" height="1080" alt="FROSTIQ" src="https://github.com/user-attachments/assets/b7764426-3bd2-4d2f-a98e-fec84a481b2b" />
# FrostIQ - Smart Refrigerator Monitoring System

An open-source IoT retrofit module that transforms conventional refrigerators into intelligent appliances through real-time monitoring, predictive maintenance, and food safety analytics. FROSTIQ brings smart refrigeration to existing refrigerators without requiring users to purchase expensive premium appliances.

---
## Vision

Technology should not be limited by the cost of the appliance.
FROSTIQ exists to make intelligent refrigeration accessible to every household, restaurant, clinic, and healthcare facility by upgrading existing refrigerators instead of replacing them.
Our goal is simple: make smart refrigeration affordable, sustainable, and open for everyone.

---
## About the Project

FROSTIQ was created to address a simple question:
> Why should intelligent refrigeration only be available to people who can afford a new smart refrigerator?

Millions of households, restaurants, clinics, and small businesses continue to use perfectly functional refrigerators that lack even the most basic monitoring capabilities. These appliances cannot detect food spoilage, identify compressor failures, monitor power consumption, or notify users when the door has been left open.
Instead of replacing existing refrigerators, FROSTIQ upgrades them.
By combining embedded hardware, IoT connectivity, and a mobile application, our system converts any compatible refrigerator into a smart monitoring system while keeping the overall solution affordable and accessible.

---

## Market Gap

The current appliance market is divided into two extremes.

- Conventional refrigerators provide no intelligent monitoring.
- Premium smart refrigerators offer advanced features but remain financially inaccessible for a large section of society.

There is very little available for users who simply want to upgrade the refrigerator they already own.
This affects:
- Homes
- Small restaurants
- Cloud kitchens
- Clinics
- Donation-funded hospitals
- Rural healthcare centres
FROSTIQ bridges this gap by providing a modular retrofit solution instead of requiring complete appliance replacement.

---

## Problem Statement

How can we make intelligent refrigerator monitoring accessible without forcing users to purchase an entirely new appliance?
FROSTIQ addresses this challenge by developing an affordable retrofit module capable of monitoring environmental conditions, food quality, door activity, appliance health, and energy consumption while remaining simple to install and scalable for different refrigerator models.

---

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
