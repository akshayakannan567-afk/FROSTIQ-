# FrostIQ

## Intelligence for Every Refrigerator

### DO NOT REPLACE. UPGRADE.

The missing intelligence layer for conventional refrigerators.

<p align="center">
<img width="1920" height="1080" alt="FROSTIQ" src="https://github.com/user-attachments/assets/b7764426-3bd2-4d2f-a98e-fec84a481b2b" />
</p>

---

## The Problem

Conventional refrigerators operate without real-time visibility.
Users cannot monitor appliance health, storage conditions, or energy usage until problems have already occurred. Existing appliances provide cooling but offer no insight into operating conditions, maintenance requirements, or energy efficiency.
Advanced smart refrigerators solve some of these problems, but they remain expensive and require replacing an otherwise functional appliance.
Conventional refrigerators provide cooling.
They do not provide intelligence.

### Current Limitations

- No real-time temperature monitoring
- No current sensors can handle gaps as small as 1mm or less than that
- No visibility into storage conditions
- No visibility into abnormal energy consumption
- No appliance health assessment
- No preventive maintenance reminders
- No cleaning schedule recommendations
- No intelligent maintenance guidance

---

## Our Solution

Introducing **FrostIQ**.

FrostIQ is an AI-assisted IoT retrofit platform that transforms conventional refrigerators into intelligent connected appliances without requiring complete appliance replacement.
Using embedded sensing, cloud connectivity, and AI-assisted maintenance guidance, FrostIQ continuously monitors refrigerator conditions, provides appliance health insights, estimates electricity consumption, and delivers personalized maintenance recommendations through a mobile application.
Instead of replacing an existing refrigerator with an expensive smart appliance, FrostIQ upgrades the one users already own.

---

## About FrostIQ

FrostIQ combines an ESP32-based embedded system, Firebase Realtime Database, a Flask backend, and a Flutter mobile application into a unified monitoring platform.
The system continuously monitors:

- Temperature
- Air Quality
- Door Status
- Voltage
- Current
- Power Consumption
- Energy Consumption

All telemetry is synchronized with Firebase, analysed by the backend, and presented through a mobile application that provides real-time monitoring, appliance health analysis, and AI-assisted maintenance guidance.

<p align="center">
<img width="1370" height="1148" alt="System Overview" src="https://github.com/user-attachments/assets/c3d6d82b-05c6-4495-a524-81821a25aa18" />
</p>

---

## Core Features

- Real-Time Monitoring
- Cloud Synchronization
- AI-Assisted Maintenance Guidance
- Appliance Health Score
- Smart Notifications
- Personalized Maintenance Scheduling
- Cleaning Reminders
- Energy Monitoring
- Electricity Bill Estimation
- QR-Based Device Registration
- Live Dashboard
- Remote Appliance Monitoring

---

## How FrostIQ Works

Every sensor reading is transformed into actionable insights through continuous monitoring and intelligent processing.

<p align="center">
<img width="1672" height="678" alt="Workflow" src="https://github.com/user-attachments/assets/59a84d0a-6ae7-4ecf-b93e-9e120c71157c" />
</p>

### Workflow

### 1. Sense

The ESP32 continuously collects data from:

- DHT22 Temperature Sensor
- MQ-135 Air Quality Sensor
- Reed Switch Door Sensor
- PZEM-004T Energy Monitoring Module

### 2. Process

The ESP32 validates sensor readings and detects abnormal operating conditions before transmitting telemetry to the cloud.

### 3. Synchronize

Validated telemetry is securely synchronized with Firebase Realtime Database.

### 4. Analyse

The backend evaluates incoming data to:

- Calculate appliance health
- Detect abnormal conditions
- Estimate energy consumption
- Generate maintenance insights

### 5. AI Assistance

The AI assistant analyses live appliance telemetry and provides:

- Maintenance recommendations
- Troubleshooting guidance
- Cleaning recommendations
- Appliance-specific assistance

### 6. Notify

The mobile application receives:

- Live telemetry updates
- Smart notifications
- Maintenance reminders
- Appliance health alerts
- Energy usage summaries

---

## System Architecture

FrostIQ follows a modular cloud-connected architecture that separates embedded sensing, cloud synchronization, AI processing, and mobile interaction.

<p align="center">
<img width="1057" height="860" alt="Architecture" src="https://github.com/user-attachments/assets/c288b6a3-7183-4c9a-9d29-6466954a33de" />
</p>

### Architecture Overview

```
                    Sensors
        ┌──────────────────────────┐
        │ DHT22                    │
        │ MQ-135                   │
        │ Reed Switch              │
        │ PZEM-004T                │
        └─────────────┬────────────┘
                      │
                  ESP32 Firmware
                      │
             Firebase Realtime Database
                      │
              Flask Backend Server
                      │
      ┌───────────────┴───────────────┐
      │                               │
AI Maintenance Assistant      Notification Engine
      │                               │
      └───────────────┬───────────────┘
                      │
              Flutter Mobile App
```

### Architecture Highlights

- Modular Retrofit Architecture
- Edge Processing using ESP32
- Firebase Cloud Synchronization
- Flask Backend for AI Processing
- AI-Assisted Maintenance Guidance
- Real-Time Mobile Dashboard
- Scalable Cloud Infrastructure

---
## Prototype

The FrostIQ prototype has been developed as a compact retrofit module that can be installed on conventional refrigerators without modifying the appliance's internal circuitry.

The prototype integrates environmental sensing, energy monitoring, cloud connectivity, and intelligent analytics into a single embedded platform.

The system continuously monitors refrigerator conditions and synchronizes live telemetry with Firebase, enabling users to remotely monitor appliance performance through the mobile application.

<p align="center">
<img width="850" alt="Prototype" src="https://github.com/user-attachments/assets/YOUR-PROTOTYPE-IMAGE" />
</p>

---

## Hardware Components

FrostIQ combines multiple sensors with an ESP32 microcontroller to provide continuous monitoring of refrigerator operating conditions.

| Component | Purpose |
|-----------|---------|
| ESP32 | Main Microcontroller |
| DHT22 | Temperature Monitoring |
| MQ-135 | Air Quality Monitoring |
| Reed Switch | Door Status Detection |
| PZEM-004T | Voltage, Current, Power and Energy Monitoring |
| Active Buzzer | Local Alert System |
| Wi-Fi Module (ESP32) | Cloud Connectivity |

---

## Hardware Block Diagram

The embedded hardware continuously collects environmental and electrical parameters before transmitting them to the cloud.

<p align="center">
<img width="1100" alt="Hardware Block Diagram" src="https://github.com/user-attachments/assets/YOUR-HARDWARE-DIAGRAM" />
</p>

### Data Flow

```
Temperature Sensor
                  │
Air Quality Sensor│
                  │
Door Sensor       │
                  ▼
               ESP32
                  │
        Energy Monitoring Module
                  │
                  ▼
      Firebase Realtime Database
                  │
             Flask Backend
                  │
                  ▼
      Flutter Mobile Application
```

---

## Mobile Application

FrostIQ includes a Flutter-based mobile application that allows users to monitor appliance conditions from anywhere.

The application communicates with Firebase to display live telemetry while the Flask backend processes appliance analytics and AI-assisted maintenance guidance.

Users receive real-time updates, maintenance reminders, appliance health information, and energy insights through a simple dashboard.

<p align="center">
<img width="1000" alt="Mobile Application" src="https://github.com/user-attachments/assets/YOUR-APP-SCREENSHOT" />
</p>

### Application Features

- Live Dashboard
- AI Maintenance Assistant
- Appliance Health Score
- Smart Notifications
- Energy Monitoring
- Electricity Bill Estimation
- Maintenance Scheduling
- Cleaning Reminders
- QR-Based Device Registration

---

## Application Demonstration

The following demonstration showcases the complete FrostIQ workflow, including device registration, real-time monitoring, AI-assisted maintenance guidance, appliance health monitoring, smart notifications, and energy analytics.

Replace the placeholder below with your uploaded GitHub video.

```text
https://github.com/user-attachments/assets/your-demo-video
```

---

## AI Maintenance Assistant

FrostIQ includes an AI-assisted maintenance assistant that provides contextual guidance based on live refrigerator telemetry.

Instead of displaying only sensor readings, the assistant analyses appliance conditions and explains potential issues while recommending practical maintenance actions.

The AI assistant retrieves telemetry from Firebase through the Flask backend and generates responses using a Large Language Model.

### Capabilities

- Explains abnormal sensor readings
- Provides refrigerator maintenance guidance
- Answers appliance-related questions
- Suggests preventive maintenance
- Recommends cleaning schedules
- Assists with troubleshooting

### AI Workflow

```
ESP32
   │
   ▼
Firebase Realtime Database
   │
   ▼
Flask Backend
   │
   ▼
OpenAI API
   │
   ▼
Flutter Mobile Application
```

---

## Appliance Health Score

FrostIQ continuously evaluates the overall condition of the refrigerator using multiple sensor readings.

The health score provides users with a simple indication of appliance condition while helping identify potential issues before they become failures.

### Parameters Considered

- Temperature
- Air Quality
- Door Status
- Power Consumption
- Active Alerts

| Health Score | Status |
|--------------|--------|
| 90–100 | Excellent |
| 75–89 | Good |
| 60–74 | Maintenance Recommended |
| Below 60 | Immediate Attention Required |

The health score is recalculated whenever new telemetry is received, ensuring users always have an up-to-date assessment of appliance condition.

---

## Smart Maintenance Engine

Each refrigerator registered with FrostIQ maintains its own appliance profile.

Instead of sending generic reminders, FrostIQ generates personalized maintenance schedules using appliance information together with live telemetry.

### Appliance Profile

- Brand
- Model Number
- Purchase Date
- Warranty Expiry
- Household Size
- Usage Pattern
- Last Cleaning Date
- Last Service Date
- Notification Preferences

Based on this information, FrostIQ automatically schedules:

- Cleaning Reminders
- Preventive Maintenance
- Warranty Notifications
- Appliance Health Alerts

Users can update maintenance history directly within the application, allowing reminder schedules to automatically adjust based on the latest service activity.

---

## Smart Notifications

FrostIQ generates notifications based on both appliance history and live operating conditions.

Notifications are designed to inform users about important appliance events before they develop into larger problems.

### Notification Types

- Door Left Open
- High Temperature
- Poor Air Quality
- High Energy Consumption
- Cleaning Reminder
- Preventive Maintenance Reminder
- Appliance Health Warning
- Warranty Reminder

Notifications are stored in Firebase and synchronized across the mobile application in real time.

---

## Energy Monitoring and Electricity Bill Estimation

FrostIQ continuously monitors electrical parameters using the PZEM-004T Energy Monitoring Module.

Rather than displaying only instantaneous power, the application converts measured energy into meaningful usage statistics.

### Live Energy Parameters

- Voltage
- Current
- Power
- Energy Consumption

### Energy Analytics

- Daily Energy Usage
- Weekly Energy Usage
- Monthly Energy Usage
- Estimated Annual Energy Usage

### Electricity Bill Estimation

Users can configure their local electricity tariff within the application.

Using measured energy consumption, FrostIQ estimates:

- Daily Electricity Cost
- Weekly Electricity Cost
- Monthly Electricity Cost
- Estimated Annual Cost

| Parameter | Example |
|-----------|---------|
| Current Power | 82 W |
| Daily Consumption | 1.52 kWh |
| Monthly Consumption | 45.60 kWh |
| Electricity Tariff | ₹8.25/kWh |
| Estimated Monthly Bill | ₹376.20 |

These estimates provide users with greater visibility into appliance operating costs and encourage more energy-efficient usage.

---
## Dashboard Overview

The FrostIQ dashboard provides users with a centralized view of appliance performance, health, maintenance history, and energy usage.

Instead of requiring users to interpret raw sensor values, the dashboard presents meaningful insights that simplify monitoring and maintenance.

<p align="center">
<img width="1000" alt="Dashboard" src="https://github.com/user-attachments/assets/YOUR-DASHBOARD-SCREENSHOT" />
</p>

### Dashboard Features

- Live Temperature Monitoring
- Air Quality Status
- Door Status
- Voltage Monitoring
- Current Monitoring
- Live Power Consumption
- Daily Energy Usage
- Weekly Energy Usage
- Monthly Energy Usage
- Estimated Electricity Bill
- Appliance Health Score
- AI Maintenance Assistant
- Smart Notifications
- Maintenance History

---

## Repository Structure

```text
FrostIQ/
│
├── backend/
│   ├── app.py
│   ├── routes.py
│   ├── ai_service.py
│   ├── firebase_service.py
│   ├── notification_service.py
│   ├── scheduler.py
│   ├── prompts.py
│   ├── config.py
│   ├── requirements.txt
│   ├── .env.example
│   └── serviceAccountKey.json
│
├── esp32/
│   ├── frostiq_firmware.ino
│   └── libraries/
│
├── mobile_app/
│   ├── android/
│   ├── ios/
│   ├── lib/
│   ├── assets/
│   ├── pubspec.yaml
│   └── README.md
│
├── landing_page/
│
├── manufacturing/
│   ├── qr_generator.py
│   ├── labels/
│   └── README.md
│
├── docs/
│   ├── architecture/
│   ├── diagrams/
│   └── screenshots/
│
├── LICENSE
├── .gitignore
└── README.md
```

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/FrostIQ.git

cd FrostIQ
```

---

### 2. Configure Firebase

Create a Firebase project.

Enable:

- Firebase Authentication
- Firebase Realtime Database

Download your Firebase Service Account Key and place it inside:

```text
backend/serviceAccountKey.json
```

---

### 3. Configure Environment Variables

Create a `.env` file inside the backend directory.

```env
OPENAI_API_KEY=your_api_key

FIREBASE_DATABASE_URL=https://your-project.firebaseio.com

FIREBASE_SERVICE_ACCOUNT=serviceAccountKey.json

SECRET_KEY=your_secret_key

HOST=0.0.0.0

PORT=5000

OPENAI_MODEL=gpt-4o-mini
```

---

### 4. Install Backend Dependencies

```bash
cd backend

pip install -r requirements.txt
```

---

### 5. Run the Flask Backend

```bash
python app.py
```

The backend will start at:

```text
http://localhost:5000
```

---

### 6. Upload the ESP32 Firmware

Flash the firmware using the Arduino IDE.

Update the following before uploading:

- Wi-Fi Credentials
- Firebase Configuration
- Device ID

---

### 7. Run the Flutter Application

```bash
cd mobile_app

flutter pub get

flutter run
```

### 8. Register the Refrigerator

Scan the generated QR code to register the refrigerator.

The application will automatically begin displaying live telemetry.

## Technology Stack

| Layer | Technology |
|--------|------------|
| Embedded System | ESP32 |
| Firmware | Arduino C++ |
| Sensors | DHT22, MQ-135, Reed Switch, PZEM-004T |
| Backend | Flask |
| Programming Language | Python |
| Mobile Application | Flutter |
| Cloud Database | Firebase Realtime Database |
| Authentication | Firebase Authentication |
| AI | OpenAI API |
| Version Control | Git & GitHub |

## Why FrostIQ?

| Conventional Refrigerator | FrostIQ |
|--------------------------|----------|
| Temperature only | Complete appliance monitoring |
| No cloud connectivity | Firebase synchronization |
| No maintenance guidance | AI-assisted recommendations |
| No appliance health analysis | Live health score |
| No notifications | Smart alerts |
| No energy analytics | Live energy monitoring |
| No bill estimation | Estimated electricity cost |
| Manual maintenance | Personalized maintenance scheduling |

## Future Scope

FrostIQ has been designed with a modular architecture that supports future expansion without requiring hardware replacement.

Planned enhancements include:

- Predictive Maintenance using Machine Learning
- Firebase Cloud Messaging
- Food Inventory Detection
- Automatic Shopping List Generation
- Multi-Refrigerator Support
- Over-the-Air Firmware Updates
- Advanced Energy Analytics
- Appliance Usage Forecasting
- Web Dashboard

---

## Project Status

**Current Status:** Active Development

### Completed

- ESP32 Firmware
- Sensor Integration
- Firebase Integration
- Flutter Mobile Application
- Flask Backend
- AI Maintenance Assistant
- Smart Notification Engine
- Appliance Health Score
- Energy Monitoring
- Electricity Bill Estimation
- QR-Based Device Registration
- Predictive Maintenance
- Multi-Device Support

### In Progress

- Web Dashboard
- OTA Firmware Updates

---

## Contributors

| Name | Responsibility |
|------|----------------|
| Vinay E | Team Lead, Backend Development and System Integration |
| Sara | Embedded Systems and Hardware Development |
| Akshaya R K | Documentation, UI Design and Project Presentation |
| Aishwarya S | Product Strategy, Research and Testing |

---

## License

This project is intended for educational, research, and prototype development purposes.

---

## Acknowledgements

This project was developed as part of an effort to demonstrate how existing household appliances can be upgraded using IoT, cloud computing, and artificial intelligence without requiring complete replacement.

The project integrates embedded systems, cloud infrastructure, AI-assisted maintenance guidance, and mobile application development into a single retrofit platform.

---

## Vision

FrostIQ demonstrates that innovation is not always about creating new products.

Sometimes, the greatest impact comes from making existing technology more intelligent, more sustainable, and more accessible.

By combining embedded sensing, cloud connectivity, and AI-assisted maintenance guidance, FrostIQ extends the capabilities of conventional refrigerators while reducing unnecessary electronic waste.

---

<p align="center">

**FrostIQ**

*Intelligence for Every Refrigerator.*

</p>
