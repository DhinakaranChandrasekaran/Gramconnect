# GramConnect - Complete Project Structure

## 📁 Root Directory Structure
```
gramconnect/
├── README.md                          # Project documentation
├── package.json                       # Node.js project configuration
├── project-structure.md               # This file
├── backend/                           # Spring Boot Backend
│   ├── pom.xml                        # Maven configuration
│   ├── src/
│   │   └── main/
│   │       ├── java/com/gramconnect/
│   │       │   ├── GramConnectApplication.java    # Main application
│   │       │   ├── controller/                    # REST API Controllers
│   │       │   │   ├── AuthController.java        # Authentication endpoints
│   │       │   │   ├── ComplaintController.java   # Complaint management
│   │       │   │   ├── AdminController.java       # Admin operations
│   │       │   │   ├── FileController.java        # File upload/download
│   │       │   │   └── GarbageScheduleController.java # Schedule management
│   │       │   ├── dto/                           # Data Transfer Objects
│   │       │   │   ├── AuthRequest.java           # Authentication requests
│   │       │   │   ├── AuthResponse.java          # Authentication responses
│   │       │   │   ├── ComplaintRequest.java      # Complaint creation
│   │       │   │   └── OtpRequest.java            # OTP verification
│   │       │   ├── model/                         # MongoDB Entities
│   │       │   │   ├── User.java                  # User entity
│   │       │   │   ├── Admin.java                 # Admin entity
│   │       │   │   ├── Complaint.java             # Complaint entity
│   │       │   │   ├── GarbageSchedule.java       # Schedule entity
│   │       │   │   └── OtpVerification.java       # OTP entity
│   │       │   ├── repository/                    # Data Access Layer
│   │       │   │   ├── UserRepository.java        # User data operations
│   │       │   │   ├── AdminRepository.java       # Admin data operations
│   │       │   │   ├── ComplaintRepository.java   # Complaint data operations
│   │       │   │   ├── GarbageScheduleRepository.java # Schedule operations
│   │       │   │   └── OtpVerificationRepository.java # OTP operations
│   │       │   ├── security/                      # Security Configuration
│   │       │   │   ├── JwtUtil.java               # JWT token utilities
│   │       │   │   ├── JwtAuthenticationFilter.java # JWT filter
│   │       │   │   └── SecurityConfig.java        # Security configuration
│   │       │   └── service/                       # Business Logic Layer
│   │       │       ├── AuthService.java           # Authentication logic
│   │       │       ├── ComplaintService.java      # Complaint business logic
│   │       │       ├── GarbageScheduleService.java # Schedule logic
│   │       │       ├── EmailService.java          # Email notifications
│   │       │       ├── SmsService.java            # SMS notifications
│   │       │       └── FileStorageService.java    # File management
│   │       └── resources/
│   │           └── application.yml                # Application configuration
│   └── uploads/                                   # File upload directory
│       └── images/                                # Uploaded complaint images
└── frontend/                                      # Flutter Frontend
    ├── pubspec.yaml                               # Flutter dependencies
    ├── android/                                   # Android configuration
    │   └── app/
    │       ├── build.gradle                       # Android build config
    │       └── src/main/AndroidManifest.xml       # Android permissions
    ├── ios/                                       # iOS configuration
    │   └── Runner/
    │       └── Info.plist                         # iOS permissions
    └── lib/                                       # Flutter source code
        ├── main.dart                              # App entry point
        ├── core/                                  # Core functionality
        │   ├── config/
        │   │   └── app_config.dart                # App configuration
        │   ├── models/                            # Data models
        │   │   ├── user_model.dart                # User data model
        │   │   └── complaint_model.dart           # Complaint data model
        │   ├── providers/                         # State management
        │   │   ├── auth_provider.dart             # Authentication state
        │   │   ├── complaint_provider.dart        # Complaint state
        │   │   └── theme_provider.dart            # Theme state
        │   ├── routes/
        │   │   └── app_routes.dart                # Navigation configuration
        │   ├── services/                          # API services
        │   │   ├── auth_service.dart              # Authentication API
        │   │   ├── complaint_service.dart         # Complaint API
        │   │   ├── offline_service.dart           # Offline storage
        │   │   └── notification_service.dart      # Local notifications
        │   └── theme/
        │       └── app_theme.dart                 # UI theme configuration
        └── features/                              # Feature modules
            ├── auth/                              # Authentication feature
            │   ├── screens/
            │   │   ├── welcome_screen.dart        # Welcome/intro screen
            │   │   ├── login_screen.dart          # Login screen
            │   │   ├── signup_screen.dart         # Registration screen
            │   │   ├── otp_verification_screen.dart # OTP verification
            │   │   └── profile_completion_screen.dart # Profile completion
            │   └── widgets/
            │       ├── auth_form_field.dart       # Custom form field
            │       └── auth_button.dart           # Custom button
            ├── home/                              # Dashboard feature
            │   ├── screens/
            │   │   └── home_screen.dart           # Main dashboard
            │   └── widgets/
            │       ├── stats_card.dart            # Statistics card
            │       ├── category_card.dart         # Category selection
            │       └── recent_complaints.dart     # Recent complaints list
            ├── complaints/                        # Complaint management
            │   ├── screens/
            │   │   ├── new_complaint_screen.dart  # Create complaint
            │   │   ├── complaint_history_screen.dart # Complaint list
            │   │   └── complaint_detail_screen.dart # Complaint details
            │   └── widgets/
            │       ├── complaint_card.dart        # Complaint list item
            │       ├── complaint_status_timeline.dart # Status timeline
            │       ├── feedback_dialog.dart       # Feedback form
            │       ├── category_selector.dart     # Category selection
            │       ├── image_picker_widget.dart   # Image upload
            │       ├── location_picker.dart       # GPS location
            │       └── filter_chips.dart          # Filter options
            └── profile/                           # User profile
                ├── screens/
                │   └── profile_screen.dart        # Profile management
                └── widgets/
                    ├── profile_info_card.dart     # Profile information
                    └── profile_menu_item.dart     # Profile menu items
```

## 🏗️ Architecture Overview

### **Backend Architecture (Spring Boot)**
- **Controller Layer**: REST API endpoints with proper HTTP methods
- **Service Layer**: Business logic and data processing
- **Repository Layer**: MongoDB data access with Spring Data
- **Security Layer**: JWT authentication and authorization
- **DTO Layer**: Clean request/response objects

### **Frontend Architecture (Flutter)**
- **Provider Pattern**: State management across the app
- **Service Layer**: API communication and data handling
- **Feature-based Structure**: Modular organization by functionality
- **Responsive Design**: Adaptive UI for all screen sizes
- **Offline Support**: Local storage with automatic sync

## 🔧 Technology Stack Details

### **Backend Technologies**
- **Spring Boot 3.2**: Modern Java framework
- **MongoDB Atlas**: Cloud NoSQL database
- **Spring Security**: Authentication and authorization
- **JWT**: Stateless token-based authentication
- **Maven**: Dependency management and build tool
- **JavaMailSender**: Email notifications
- **Fast2SMS**: SMS notifications

### **Frontend Technologies**
- **Flutter 3.2+**: Cross-platform mobile framework
- **Provider**: State management solution
- **GoRouter**: Declarative routing
- **Hive**: Local database for offline storage
- **HTTP/Dio**: API communication
- **Image Picker**: Camera and gallery access
- **Geolocator**: GPS location services
- **Local Notifications**: Push notifications

### **Database Schema**
```
MongoDB Collections:
├── users                    # User profiles and authentication
├── admins                   # Admin accounts and permissions
├── complaints               # Complaint records with status
├── garbage_schedules        # Collection schedules by area
├── otp_verifications        # Temporary OTP storage
└── feedback                 # User satisfaction ratings
```

## 📱 Screen Flow Architecture

### **Authentication Flow**
```
Welcome Screen (5s auto-nav)
    ↓
Login/Signup Choice
    ↓
Login: Email/Phone + Password → OTP → Home
Signup: Details → Phone OTP → Profile Completion → Home
```

### **Main App Flow**
```
Home Dashboard
    ├── New Complaint → Category → Details → Image → GPS → Submit
    ├── Complaint History → Filter → Detail View → Actions
    ├── Profile → Edit → Save
    └── Notifications → View → Actions
```

### **Admin Flow**
```
Admin Login
    ↓
Admin Dashboard
    ├── Complaint Management → View → Update Status
    ├── Schedule Management → Upload → Manage
    └── User Feedback → View → Analytics
```

## 🔒 Security Architecture

### **Authentication Layers**
1. **JWT Tokens**: Stateless authentication
2. **Role-based Access**: USER vs ADMIN permissions
3. **OTP Verification**: Multi-factor authentication
4. **Password Hashing**: BCrypt encryption
5. **Rate Limiting**: OTP request limits

### **Data Protection**
- **Input Validation**: Server-side validation
- **SQL Injection Prevention**: MongoDB parameterized queries
- **CORS Protection**: Cross-origin request security
- **HTTPS Enforcement**: Secure data transmission

## 📊 Data Flow Architecture

### **API Communication**
```
Flutter App → HTTP/HTTPS → Spring Boot → MongoDB Atlas
    ↑                                        ↓
Local Storage ← Offline Sync ← Response Processing
```

### **Offline Support**
```
User Action → Check Connectivity
    ├── Online: API Call → Server → Database
    └── Offline: Local Storage → Sync Queue → Auto-sync when online
```

## 🎨 UI/UX Architecture

### **Design System**
- **Material Design 3**: Modern UI components
- **Color System**: Primary, Secondary, Accent, Status colors
- **Typography**: Roboto font with hierarchical sizing
- **Spacing System**: 8px grid system
- **Component Library**: Reusable UI components

### **Responsive Design**
- **Breakpoints**: Phone, Tablet, Desktop support
- **Flexible Layouts**: Adaptive to screen sizes
- **Touch Targets**: Minimum 44px for accessibility
- **Contrast Ratios**: WCAG compliance

## 🚀 Deployment Architecture

### **Development Environment**
```
Local Development:
├── Backend: localhost:8080 (Spring Boot)
├── Database: MongoDB Atlas (Cloud)
├── Frontend: Flutter Debug Mode
└── Testing: Android Emulator/Physical Device
```

### **Production Environment**
```
Production Deployment:
├── Backend: Cloud Platform (AWS/GCP/Azure)
├── Database: MongoDB Atlas (Production Cluster)
├── Frontend: APK/AAB for Google Play Store
└── Monitoring: Application logs and metrics
```

This comprehensive project structure ensures maintainable, scalable, and production-ready code with clear separation of concerns and modern development practices.


<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="gramconnect"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to determine the Window background behind the Flutter UI. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <!-- Required to query activities that can process text, see:
         https://developer.android.com/training/package-visibility and
         https://developer.android.com/reference/android/content/Intent#ACTION_PROCESS_TEXT.

         In particular, this is used by the Flutter engine in io.flutter.plugin.text.ProcessTextPlugin. -->
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
