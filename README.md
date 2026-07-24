# FrostIQ

## Intelligence for Every Refrigerator

### DO NOT REPLACE. UPGRADE.

The missing intelligence layer for conventional refrigerators.


<p align="center">
<img width="1920" height="1080" alt="FROSTIQ" src="https://github.com/user-attachments/assets/b7764426-3bd2-4d2f-a98e-fec84a481b2b" />
</p>

## The Problem

Conventional refrigerators operate without real-time visibility.
Users cannot monitor appliance health, storage conditions, or energy usage until problems have already occurred.
Conventional refrigerators provide cooling—but not intelligence.


### Current Limitations

- No real-time temperature monitoring
- No real-time door status alerts
- No visibility into storage conditions
- No visibility into abnormal energy consumption



## Our Solution

Introducing **FrostIQ**
An intelligent retrofit platform that brings real-time monitoring, cloud connectivity, and appliance insights to conventional refrigerators.



## About FrostIQ

FrostIQ is an intelligent IoT retrofit platform designed to bring real-time monitoring, cloud connectivity, and appliance insights to conventional refrigerators.

The growing economic gap in the appliance market has made advanced smart refrigerators inaccessible to the average consumer. FrostIQ addresses this challenge by transforming existing refrigerators into intelligent connected appliances without requiring complete appliance replacement.

Using an ESP32-based hardware stack, FrostIQ continuously monitors temperature, air quality, door status, and energy consumption while providing instant alerts and remote monitoring through a connected mobile application.


<p align="center">
<img width="1370" height="1148" alt="ChatGPT Image Jul 21, 2026, 04_41_40 PM" src="https://github.com/user-attachments/assets/c3d6d82b-05c6-4495-a524-81821a25aa18" />
</p>

### Core Features

- Real-Time Monitoring
- Intelligent Alerts
- Cloud Synchronization
- Energy Analytics



## How FrostIQ Works

Every sensor reading is transformed into actionable insights through continuous monitoring and intelligent processing.


<p align="center">
<img width="1672" height="678" alt="ChatGPT Image Jul 21, 2026, 07_34_25 PM" src="https://github.com/user-attachments/assets/59a84d0a-6ae7-4ecf-b93e-9e120c71157c" />
</p>

### Workflow

1. **Sense**
   - DHT22 (Temperature & Humidity)
   - Reed Switch (Door Status)
   - MQ-135 (Air Quality)
   - PZEM-004T (Power Monitoring)

2. **Process**
   - ESP32 processes sensor data
   - Validates threshold conditions

3. **Sync**
   - Synchronizes live data with Firebase

4. **Analyze**
   - Detects abnormal conditions
   - Performs threshold-based appliance monitoring

5. **Notify**
   - Sends instant alerts
   - Updates dashboard in real time



## System Architecture

A modular IoT architecture that seamlessly connects sensing, processing, cloud synchronization, and intelligent monitoring.


<p align="center">
<img width="1057" height="860" alt="ChatGPT Image Jul 21, 2026, 11_49_55 PM" src="https://github.com/user-attachments/assets/c288b6a3-7183-4c9a-9d29-6466954a33de" />
</p>

### Architecture Highlights

- Edge Processing — Threshold validation happens locally.
- Cloud Synchronization — Secure live data synchronization.
- Modular Retrofit — Compatible with existing refrigerators.
- Real-Time Monitoring — Instant alerts and live dashboards.



## Prototype
<p align="center">
<img width="1349" height="1166" alt="ChatGPT Image Jul 22, 2026, 07_16_41 PM" src="https://github.com/user-attachments/assets/1aaaa324-23b3-4626-a431-6c746c67938d" />
</p>

### Hardware Components

- ESP32 DevKit
- MQ-135 Gas Sensor
- DHT22 Temperature Sensor
- Magnetic Reed Switch (MC-38)
- PZEM-004T Power Monitor
- Active Buzzer
- Breadboard
- 5V USB Power Supply

## Hardware Block Diagram

The following diagram illustrates the complete hardware interconnection of the FrostIQ prototype, showing how the ESP32 communicates with sensors, power monitoring modules, alert systems, and the cloud-connected dashboard. It demonstrates the modular retrofit architecture that enables real-time monitoring, edge processing, and intelligent refrigerator analytics.

<p align="center">
<img width="1683" height="934" alt="ChatGPT Image Jul 24, 2026, 02_47_53 PM" src="https://github.com/user-attachments/assets/2b5fe2cd-7909-4c16-b250-6d48cb18f8ad" />
</p>



## Why FrostIQ?

Designed for real homes, not just demos.



<!-- Comparison -->

| Smart Refrigerator | FrostIQ Retrofit |
|-------------------|------------------|
| ₹2.5L+ | ₹5,000 |
| Replace the Appliance | Upgrade in ~15 Minutes |
| Factory Integrated | Modular Retrofit |
| New Units Only | Existing Refrigerators |
| Replace Entire Appliance | No Appliance Replacement |
| High Initial Investment | Approximately 95% Lower Upgrade Cost |



## Beyond FrostIQ

One Platform. Endless Possibilities.


<p align="center">
<img width="1536" height="759" alt="ChatGPT Image Jul 23, 2026, 07_50_41 PM" src="https://github.com/user-attachments/assets/b0069f36-9e77-4c83-8a3e-dcd20681d79f" />
</p>

### Future Applications

- Smart Homes
- Healthcare
- Restaurants
- Cold Chain Logistics
- Commercial Refrigeration



## Project Status

> **Current Stage:** In Development

The current prototype successfully demonstrates real-time refrigerator monitoring through an ESP32-based IoT architecture.
The platform will continue to evolve with additional sensing capabilities, improved mobile experiences, and advanced analytics while maintaining its core philosophy:

**DO NOT REPLACE. UPGRADE**


## Repository Structure

```Structure
frostiq_project/
├── manufacturing/
├── mobile_app/
├── esp32/
└── landing_page/
```

## 🚀 Quick Start

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

## 📱 User Flow
1. Customer scans QR sticker → Opens app (or downloads it)
2. App shows WiFi setup screen
3. Customer joins "Frostiq_XXXX" hotspot
4. Enters home WiFi credentials
5. Names their device
6. Live dashboard opens with sensor data

## 🔔 Notifications
- Door open > 30s → Critical alert
- Temperature > 10°C → Critical alert
- Gas level > 700 → Warning
- Power > 300W → Warning

## 🎨 Theme
- Dark theme with cyan (#00E5FF) accents
- Cards: #141824
- Background: #0A0E1A

## Team: Powerhouse

| Name | Role |
|------|------|
| Vinay E | Team Lead & Software Development |
| Sara | Hardware Development |
| Akshaya R K | Documentation |
| Aishwarya S | Product Strategy & Vision |



> **Innovation isn't building new things. It's making existing things smarter.**
**FrostIQ isn't another smart refrigerator.**
**It's intelligence for every refrigerator.**
