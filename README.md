GramConnect – Smart Village Grievance & Civic Service Reporting System

GramConnect is a cross-platform application (Flutter frontend + Spring Boot backend) that enables rural citizens to:

Report civic issues like garbage problems, water failures, drainage blocks, and electricity outages.

View garbage collection schedules.

Receive OTP-based login & signup (Email, Phone, Aadhaar OTP).

Track missed pickups.

Allow admins to manage complaints, users, and schedules.

Table of Contents

Project overview

Features

Prerequisites

Project paths on this machine

Backend Setup (commands)

Frontend Setup (commands)

Environment / application.yml (exact config)

Running the Application (step-by-step)

OTP Debug Mode & SnackBar display requirement

API Testing (quick reference)

Verification checklist (PASS/FAIL)

Troubleshooting

Project Structure (summary)

Security notes & warnings

Contact

Project overview

GramConnect is a Flutter mobile app with a Spring Boot REST API backed by MongoDB. It implements OTP-based auth (email/phone/Aadhaar), complaint creation and lifecycle, garbage schedule viewing and missed-pickup reporting, admin functionality (dashboard, complaint management, user management), and notifications.

Features

OTP-based Authentication

Email OTP (via SMTP)

Phone OTP (for testing logged to backend console or returned in debug mode)

Aadhaar OTP (for testing logged to backend console or returned in debug mode)

User Features

Register & Login with OTP

Profile completion (district, panchayat, ward, home address)

Aadhaar verification flag

Create complaints (with image and location)

View complaint history

View garbage schedules & report missed pickups

Admin Features

Admin login

Admin dashboard (statistics)

Complaint management (list, filter, update status, admin response)

Missed pickup management

User management

Super-admin-only admin creation endpoint

Notifications

Local in-app SnackBar notifications for OTP display (for testing; SnackBar visible ~10 seconds; no popups)

Notification history persisted in backend and retrievable by app

Prerequisites

Java 21 (LTS)

Flutter 3.32.8 (stable) with Dart 3.8.1

Maven (if using mvn) / Gradle wrapper is supported in project

MongoDB (Atlas cluster or local instance)

Internet access for SMTP (email OTP) or stubbed email sender for testing

Android emulator or physical device to run the Flutter app

Project paths on this machine

Frontend path: D:\Flutterprojects\gramconnect-frontend

Backend path: D:\Flutterprojects\gramconnect-backend

Backend Setup (commands)

Open a terminal and run:

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

OTP Debug Mode & SnackBar display requirement

For easier testing:

Backend:

When APP_DEBUG=true (set as an environment variable), OTP values may be included in API responses (for testing) and always logged to the backend console.

When APP_DEBUG=false (production), OTP values must not be returned in API responses; they are only logged server-side (or sent via email/SMS).

Frontend (mandatory, no popups):

Every time an OTP is generated or resent (sign up, login, admin login, Aadhaar verification, resend OTP), the app must show a SnackBar displaying the OTP for ~10 seconds.

Use SnackBar only (no dialogs/popups). Example helper:

// lib/core/widgets/snackbars.dart
import 'package:flutter/material.dart';

void showOtpSnackBar(BuildContext context, String otp) {
  final snackBar = SnackBar(
    content: Text('Your OTP is: $otp'),
    duration: const Duration(seconds: 10),
    behavior: SnackBarBehavior.floating,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


Call showOtpSnackBar(context, otpFromResponseOrDebugLog); immediately after a successful send/resend OTP API call.

Terminal visibility:

In debug mode, generated OTPs are printed to the backend terminal logs. Check the server console if OTP delivery via email is delayed.

API Testing (quick reference)

Base API root: http://localhost:8080/api (or adjust baseUrl in frontend)

Replace placeholder values with real data. Include Authorization: Bearer <token> header when required.

Authentication

Register

curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Test User","email":"user@example.com","phoneNumber":"+911234567890","password":"Secret@123"}'


Response: { "success": true, "requiresOtpVerification": true, "debugOtp": "123456" } (debug mode may include debugOtp)

Login (email or phone)

curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"Secret@123"}'


Response: { "success": true, "requiresOtpVerification": true } (if OTP required)

Verify OTP

curl -X POST http://localhost:8080/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"identifier":"user@example.com","otp":"123456","type":"EMAIL_LOGIN"}'


Response (success): { "success": true, "token": "<JWT>", "user": { ... } }

Resend OTP

curl -X POST http://localhost:8080/api/auth/resend-otp \
  -H "Content-Type: application/json" \
  -d '{"identifier":"user@example.com","type":"EMAIL_LOGIN"}'


Aadhaar OTP (example)

# Send
curl -X POST http://localhost:8080/api/auth/aadhaar/send-otp \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <USER_TOKEN>" \
  -d '{"aadhaar":"123412341234"}'

# Verify
curl -X POST http://localhost:8080/api/auth/aadhaar/verify-otp \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <USER_TOKEN>" \
  -d '{"aadhaar":"123412341234","otp":"123456"}'

Admin

Create Admin (SUPER_ADMIN only)

curl -X POST http://localhost:8080/api/admin/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <SUPER_ADMIN_TOKEN>" \
  -d '{"fullName":"Admin One","email":"admin1@example.com","assignedVillages":["VillageA","VillageB"]}'


Admin Login

curl -X POST http://localhost:8080/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin1@example.com","password":"Secret@123"}'

Complaints

Create complaint (User)

curl -X POST http://localhost:8080/api/complaints \
  -H "Authorization: Bearer <USER_TOKEN>" \
  -F "title=Garbage not collected"
  -F "description=Garbage has not been collected for 3 days"
  -F "latitude=12.9123" \
  -F "longitude=77.6123" \
  -F "image=@/path/to/photo.jpg"


List complaints (Admin)

curl -X GET "http://localhost:8080/api/admin/complaints?status=PENDING&district=XYZ" \
  -H "Authorization: Bearer <ADMIN_TOKEN>"


Update complaint status (Admin)

curl -X PUT http://localhost:8080/api/admin/complaints/<COMPLAINT_ID>/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ADMIN_TOKEN>" \
  -d '{"status":"IN_PROGRESS","adminResponse":"Team assigned"}'

Garbage & Missed Pickups

Get schedules (User)

curl -X GET http://localhost:8080/api/garbage/schedules \
  -H "Authorization: Bearer <USER_TOKEN>"


Report missed pickup (User)

curl -X POST http://localhost:8080/api/garbage/missed-pickup \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <USER_TOKEN>" \
  -d '{"village":"VillageA","ward":"3","date":"2025-08-14"}'


Admin: list missed pickups

curl -X GET http://localhost:8080/api/admin/missed-pickups \
  -H "Authorization: Bearer <ADMIN_TOKEN>"


For full request/response shapes, see docs/API_TESTING.md (recommended: add a Postman collection).

Verification checklist (PASS/FAIL)

Fill this table during verification. Each row should have a short evidence note (command output, screenshot ref, or log snippet).

#	Step	Status (PASS/FAIL)	Evidence
1	Repo scan: list all .dart and .java files and show file counts		
2	Backend static build: mvn clean install (or ./gradlew build)		
3	Backend start: mvn spring-boot:run (or ./gradlew bootRun)		
4	Health endpoint reachable: GET /actuator/health returns UP		
5	Frontend static analysis: flutter analyze passes		
6	Frontend run/build: flutter run (or flutter build apk) works		
7	Register → OTP email flow works (email received or OTP logged)		
8	Login → OTP flow works; SnackBar shows OTP for ~10s		
9	Resend OTP works; OTP visible in SnackBar and server log		
10	Aadhaar OTP send/verify works (debug/log)		
11	Admin create with SUPER_ADMIN token works		
12	Admin login works; protected endpoints accept Admin JWT		
13	User token is forbidden from /api/admin/** (403)		
14	Complaint lifecycle: create → list (admin) → update status		
15	Missed pickup: user report → admin list/resolve		
16	Garbage schedules: backend CRUD (as applicable) → app shows schedule		
17	Notification history persists and is retrievable		
18	Profile update persists (district/panchayat/ward/home)		
19	JWT contains sub (userId), role, and expiry (exp)		
20	Deliverables present: docs, logs, zip (if required)		
Troubleshooting

Backend cannot connect to MongoDB
Verify spring.data.mongodb.uri and network access to Atlas (IP allowlist).

SMTP issues for email OTP
Confirm spring.mail.username and spring.mail.password. For Gmail, use an App Password and enable SMTP.

Flutter build errors
Run flutter clean then flutter pub get. Ensure flutter doctor is clean.

Admin APIs returning 403
Ensure your JWT token belongs to an Admin or Super Admin and you include Authorization: Bearer <token>.

OTP not received
If in debug mode, OTP is returned in response or logged in backend console. Check backend terminal logs. Also check spam folder for emails.

Location/Image permissions
Grant location and storage/camera permissions on emulator/device.

Bootstrapping first SUPER_ADMIN
If your DB is empty, create a user with role SUPER_ADMIN directly in MongoDB (temporary step). Example using mongosh:

use gramconnect;
db.users.insertOne({
  fullName: "Super Admin",
  email: "superadmin@example.com",
  passwordHash: "<bcrypt-hash>",
  role: "SUPER_ADMIN",
  createdAt: new Date(),
  enabled: true
});


Then log in / generate a token for that account to call /api/admin/create.

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

Do not commit secrets (MongoDB URI, SMTP password, JWT secret) in production. Use environment variables or a secrets manager.

Use strong JWT secrets and rotate them periodically.

OTPs must not be returned to clients in production mode; only in debug environments for testing.

Ensure Spring Security restricts:

/api/admin/create to ROLE_SUPER_ADMIN

/api/admin/** to ROLE_ADMIN

/api/user/** to authenticated users with ROLE_USER (or higher)

Contact

Maintainer: GramConnect Team

Email: gramconnectofficial@gmail.com

Issues: Use the repository’s Issues tab to report bugs or request features.
