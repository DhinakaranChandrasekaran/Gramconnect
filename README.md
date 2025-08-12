# GramConnect – Smart Village Grievance & Civic Service Reporting System

GramConnect is a cross-platform application (Flutter frontend + Spring Boot backend) that enables rural citizens to:
- Report civic issues like garbage problems, water failures, drainage blocks, and electricity outages.
- View garbage collection schedules.
- Receive OTP-based login & signup (Email, Phone, Aadhaar OTP).
- Track missed pickups.
- Allow admins to manage complaints, users, and schedules.

---

## Table of Contents

- [Project overview](#project-overview)  
- [Features](#features)  
- [Prerequisites](#prerequisites)  
- [Project paths on this machine](#project-paths-on-this-machine)  
- [Backend Setup (commands)](#backend-setup-commands)  
- [Frontend Setup (commands)](#frontend-setup-commands)  
- [Environment / application.yml (exact config)](#environment--applicationyml-exact-config)  
- [Running the Application (step-by-step)](#running-the-application-step-by-step)  
- [OTP Debug Mode & SnackBar display requirement](#otp-debug-mode--snackbar-display-requirement)  
- [API Testing (quick reference)](#api-testing-quick-reference)  
- [Troubleshooting](#troubleshooting)  
- [Project Structure (summary)](#project-structure-summary)  
- [Security notes & warnings](#security-notes--warnings)  
- [Quick checklist before running](#quick-checklist-before-running)  
- [Contact](#contact)

---

## Project overview

GramConnect is a Flutter mobile app with a Spring Boot REST API backed by MongoDB. It implements OTP-based auth (email/phone/Aadhaar), complaint creation and lifecycle, garbage schedule viewing and missed-pickup reporting, admin functionality (dashboard, complaint management, user management), and notifications.

---

## Features

- **OTP-based Authentication**
  - Email OTP (via SMTP)
  - Phone OTP (for testing logged to backend console or returned in debug mode)
  - Aadhaar OTP (for testing logged to backend console or returned in debug mode)
- **User Features**
  - Register & Login with OTP
  - Profile completion (district, panchayat, ward, home address)
  - Aadhaar verification flag
  - Create complaints (with image and location)
  - View complaint history
  - View garbage schedules & report missed pickups
- **Admin Features**
  - Admin login
  - Admin dashboard (statistics)
  - Complaint management (list, filter, update status, admin response)
  - Missed pickup management
  - User management
  - Super-admin-only admin creation endpoint
- **Notifications**
  - Local in-app SnackBar notifications for OTP display (for testing; SnackBar visible ~10 seconds)
  - Notification history persisted in backend and retrievable by app

---

## Prerequisites

- **Java 21** (LTS)  
- **Flutter 3.32.8** (stable) with **Dart 3.8.1**  
- **Maven** (if using mvn) / Gradle wrapper is supported in project  
- **MongoDB** (Atlas cluster or local instance)  
- Internet access for SMTP (email OTP) or stubbed email sender for testing  
- Android emulator or physical device to run the Flutter app

---

## Project paths on this machine

- **Frontend path:** `D:\Flutterprojects\gramconnect-frontend`  
- **Backend path:** `D:\Flutterprojects\gramconnect-backend`

---

## Backend Setup (commands)

Open a terminal and run:

```bash
cd D:\Flutterprojects\gramconnect-backend

# Build (Maven)
mvn clean install

# Run the backend
mvn spring-boot:run

If using Gradle wrapper instead:

cd D:\Flutterprojects\gramconnect-backend
./gradlew build
./gradlew bootRun
Default backend URL: http://localhost:8080

Frontend Setup (commands)
Open a terminal and run:

cd D:\Flutterprojects\gramconnect-frontend

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Run the app on device/emulator
flutter run
To build APK:

flutter build apk --release
Note: Update the backend baseUrl in lib/core/services/auth_service.dart if backend is hosted elsewhere.

Environment / application.yml (exact config)
Place this content in gramconnect-backend/src/main/resources/application.yml or use environment variables as appropriate:

spring:
  application:
    name: gramconnect-backend

  data:
    mongodb:
      uri: mongodb+srv://dhinakaran1845:QAs5x6mK7RK4hA36@gramconnect.3cvlsqc.mongodb.net/?retryWrites=true&w=majority&appName=GramConnect
      database: gramconnect

  mail:
    host: smtp.gmail.com
    port: 587
    username: gramconnectofficial@gmail.com
    password: xnvjjvucxfzfkxkk
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true
          connectiontimeout: 5000
          timeout: 5000
          writetimeout: 5000

server:
  port: 8080

jwt:
  secret: GramConnectSecretKey2024ForSmartVillageSystem
  expiration: 86400000  # 24 hours in milliseconds

otp:
  expiration: 300000  # 5 minutes in milliseconds
  max-attempts: 3

logging:
  level:
    com.gramconnect: DEBUG
Important: The above contains credentials & connection string as provided. In production, DO NOT commit secrets to the repo — store them in environment variables or a secure secrets manager.

Running the Application (step-by-step)
Ensure MongoDB is accessible (Atlas connection string above or your local MongoDB).

Start backend:

cd D:\Flutterprojects\gramconnect-backend
mvn clean install
mvn spring-boot:run
Confirm health:

curl http://localhost:8080/actuator/health
# Expect response e.g.: {"status":"UP"}
Start frontend:

cd D:\Flutterprojects\gramconnect-frontend
flutter clean
flutter pub get
flutter run

Use the app to register/login and test OTP, complaints, schedules, and admin flows.

    # OTP Debug Mode & SnackBar display requirement

API Testing (quick reference)
Base API root: http://localhost:8080/api (or adjust baseUrl in frontend)

Authentication
POST /api/auth/register

Body: { "fullName": "...", "email": "...", "phoneNumber": "...", "password": "..." }

Response: requiresOtpVerification: true when OTP flow required.

POST /api/auth/login

Body: { "email": "...", "password": "..." } or phone-based login.

Response: requiresOtpVerification: true if OTP required.

POST /api/auth/verify-otp

Body: { "identifier": "...", "otp": "...", "type": "EMAIL_LOGIN" }

Response: token and user details (on success)

POST /api/auth/resend-otp

Body: { "identifier": "...", "type": "EMAIL_LOGIN" }

Admin
POST /api/admin/create (SUPER_ADMIN only)

Body: { "fullName": "...", "email":"...", "assignedVillages": [...] }

POST /api/admin/login

Body: { "email":"...", "password":"..." }

Complaints
POST /api/complaints — Create complaint (user)

GET /api/admin/complaints — Admin: list all complaints

PUT /api/admin/complaints/{id}/status — Update status and provide adminResponse

Garbage & Missed Pickups
GET /api/garbage/schedules — Get schedules

POST /api/garbage/missed-pickup — Report missed pickup

GET /api/admin/missed-pickups — Admin list of reported missed pickups

For full request/response shapes, add to API_TESTING.md (Postman collection). Update the frontend auth_service.dart to match the backend payloads if needed.

Troubleshooting
Backend cannot connect to MongoDB: Verify spring.data.mongodb.uri and network access to Atlas.

SMTP issues for email OTP: Confirm spring.mail.username and spring.mail.password. If using Gmail, ensure app password and SMTP access.

Flutter build errors: Run flutter clean then flutter pub get. Ensure SDK path and flutter doctor are clean.

Admin APIs returning 403: Ensure your JWT token was created for an Admin or Super Admin role and include Authorization: Bearer <token> header.

OTP not received: If in debug mode OTP is returned in response or logged in backend console. Check logs.

Permissions/Location: Grant location permission for complaint location capture on emulator/device.

Project Structure (summary)

gramconnect/
│
├── gramconnect-frontend/    # Flutter mobile app
│   ├── lib/
│   │   ├── core/            # Providers, services, routes, theme
│   │   ├── features/        # auth, admin, complaints, garbage, profile, etc.
│   │   └── main.dart
│   └── pubspec.yaml
│
├── gramconnect-backend/     # Spring Boot backend
│   ├── src/main/java/com/gramconnect/
│   │   ├── controller/
│   │   ├── dto/
│   │   ├── model/
│   │   ├── repository/
│   │   ├── service/
│   │   ├── security/
│   │   └── GramConnectApplication.java
│   ├── src/main/resources/
│   │   └── application.yml
│   └── pom.xml
│
└── README.md

Security notes & warnings

Quick checklist before running
 MongoDB Atlas or local MongoDB is available and MONGODB_URI configured correctly.

 SMTP credentials are valid (or EmailService is stubbed for development).

 Java 21 installed and available in PATH.

 Flutter 3.32.8 installed and emulator/device setup.

 Backend built (mvn clean install) and started.

 Frontend dependencies installed (flutter pub get) and app runs.