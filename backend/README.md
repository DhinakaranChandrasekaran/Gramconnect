# GramConnect - Smart Village Grievance & Civic Service Reporting System

A comprehensive full-stack mobile-first civic service reporting and grievance management system designed for rural communities in India.

## 🏗️ Technology Stack

- **Frontend**: Flutter (Cross-platform mobile app for Android/iOS)
- **Backend**: Spring Boot (Java + Maven)
- **Database**: MongoDB Atlas
- **Authentication**: Gmail OAuth + Phone OTP + Password-based
- **Notifications**: Email SMTP + Fast2SMS

## 🚀 Features

### 👤 User Features
- **Multi-Authentication**: Gmail OAuth, Phone OTP, Password-based login
- **Profile Completion**: District/Panchayat/Ward selection with Aadhaar verification
- **Complaint Reporting**: Report civic issues with image upload and GPS location
- **Real-time Tracking**: Track complaint status and progress
- **24-Hour Reminders**: Automated reminder system for pending complaints
- **Garbage Schedules**: View collection schedules with 30-minute alerts
- **Offline Support**: Report complaints offline with auto-sync
- **Profile Management**: Comprehensive user profile with editing capabilities
- **Feedback System**: Rate resolved complaints

### 🧑‍💼 Admin Features
- **Dashboard**: Comprehensive overview with statistics and trends
- **Complaint Management**: View, filter, and update complaint status
- **Schedule Management**: Upload and manage garbage collection schedules
- **User Management**: View user feedback and analytics
- **Response System**: Handle reminders and user communications

## 📱 Mobile App Screens

### User Screens
1. **Welcome Screen** - Animated intro with auto-navigation
2. **Login Screen** - Email/Phone + Password with OTP verification
3. **Signup Screen** - Complete registration with phone OTP
4. **Profile Completion** - District/Panchayat/Ward + Aadhaar verification
5. **User Dashboard (Home)** - Statistics and quick actions
6. **New Complaint Screen** - Report issues with image/GPS
7. **Complaint History Screen** - View and filter complaints
8. **Complaint Detail View** - Detailed complaint information
9. **Send Reminder Screen** - 24-hour reminder system
10. **Garbage Collection Schedule Screen** - View pickup schedules
11. **Profile Page** - User profile management
12. **Feedback Screen** - Rate and review resolved complaints

### Admin Screens
1. **Admin Login Screen** - Secure admin authentication
2. **Admin Dashboard** - Overview with statistics
3. **Complaint Management Screen** - Manage all complaints
4. **Complaint Detail View** - Admin complaint actions
5. **Reminder Response Screen** - Handle user reminders
6. **Garbage Schedule Management Screen** - Manage pickup schedules
7. **User Feedback Viewer** - Monitor user satisfaction
8. **Admin Profile Page** - Admin profile management

## 🗄️ Database Collections

- **users**: User profiles with district/panchayat/ward information
- **admins**: Admin accounts and permissions
- **complaints**: All complaint records with status tracking
- **garbage_schedules**: Collection schedules by area/ward
- **otp_verifications**: Temporary OTP storage with expiry
- **feedback**: User satisfaction ratings

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (3.0+)
- Java 17+
- Maven 3.8+
- MongoDB Atlas account
- Android Studio/VS Code

### Backend Setup (Spring Boot)
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

### Frontend Setup (Flutter)
```bash
cd frontend
flutter pub get
flutter run
```

### Environment Configuration
Update `backend/src/main/resources/application.yml` with:
- MongoDB connection string (already configured)
- Gmail SMTP credentials (already configured)
- Fast2SMS API key (add your key)

## 📡 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration with phone OTP
- `POST /api/auth/login` - User login with password/OTP
- `POST /api/auth/verify-otp` - Verify OTP for login/registration
- `POST /api/auth/resend-otp` - Resend OTP
- `POST /api/auth/admin/login` - Admin login

### Complaints
- `GET /api/complaints/user` - Get user complaints
- `POST /api/complaints` - Create new complaint
- `GET /api/complaints/{id}` - Get complaint details
- `POST /api/complaints/{id}/reminder` - Send reminder
- `POST /api/complaints/{id}/feedback` - Add feedback

### Admin
- `GET /api/admin/dashboard` - Dashboard statistics
- `GET /api/admin/complaints` - All complaints
- `PUT /api/admin/complaints/{id}/status` - Update status
- `POST /api/admin/garbage-schedule` - Upload schedule

### Files
- `GET /api/files/images/{filename}` - Get uploaded images

## 🔒 Security Features
- JWT token-based authentication with role-based access
- OTP rate limiting (3 attempts per session)
- Input validation and sanitization
- Secure password hashing with BCrypt
- CORS protection
- Request/Response DTOs for clean API design

## 📊 Monitoring & Analytics
- Real-time complaint statistics
- User engagement metrics
- Response time analytics
- Satisfaction rating trends
- Category-wise complaint analysis

## 🎨 UI/UX Features

### Design Principles
- **Material Design 3** implementation with modern aesthetics
- **Responsive design** for all device sizes (phones to tablets)
- **Touch-friendly interface** with adequate spacing for rural users
- **Consistent color scheme** with soft gradients and meaningful icons
- **Smooth animations** and transitions between screens
- **Accessibility compliance** with proper contrast ratios

### Color System
- **Primary**: Green (#2E7D32) - Represents growth and nature
- **Secondary**: Blue (#1976D2) - Trust and reliability
- **Accent**: Orange (#FF5722) - Action and urgency
- **Status Colors**: Orange (Pending), Blue (In Progress), Green (Resolved), Red (Rejected)

### Typography
- **Roboto font family** with multiple weights
- **Proper line spacing** (150% for body, 120% for headings)
- **Hierarchical text sizes** for clear information structure

## 🌐 Internationalization
- **Tamil language support** ready for implementation
- **Bilingual labels** (English + Tamil) where needed
- **Cultural considerations** for rural Indian users

## 📱 App Flow

### Authentication Flow
1. **Welcome Screen** (5-second auto-navigation)
2. **Login/Signup** choice
3. **Login**: Email/Phone + Password → OTP verification → Home
4. **Signup**: Full details → Phone OTP → Profile Completion → Home
5. **Profile Completion**: District/Panchayat/Ward + Optional Aadhaar verification

### Complaint Flow
1. **Home Dashboard** → Quick complaint categories
2. **New Complaint** → Category + Description + Image + GPS
3. **Submit** → Offline storage if no internet, sync when available
4. **Track Status** → Real-time updates and timeline
5. **24-hour reminder** → Send reminder if not resolved
6. **Feedback** → Rate satisfaction after resolution

### Admin Flow
1. **Admin Login** → Secure authentication
2. **Dashboard** → Statistics and overview
3. **Complaint Management** → Filter, view, update status
4. **Schedule Management** → Upload garbage collection schedules
5. **User Feedback** → Monitor satisfaction trends

## 🔧 Technical Architecture

### Frontend (Flutter)
```
lib/
├── main.dart                          # App entry point
├── core/                              # Core functionality
│   ├── config/app_config.dart         # App configuration
│   ├── models/                        # Data models
│   ├── providers/                     # State management
│   ├── services/                      # API services
│   ├── theme/app_theme.dart           # UI theme
│   └── routes/app_routes.dart         # Navigation
└── features/                          # Feature modules
    ├── auth/                          # Authentication
    ├── home/                          # Dashboard
    ├── complaints/                    # Complaint management
    └── profile/                       # User profile
```

### Backend (Spring Boot)
```
src/main/java/com/gramconnect/
├── GramConnectApplication.java        # Main application
├── controller/                        # REST controllers
├── dto/                              # Data transfer objects
├── model/                            # MongoDB entities
├── repository/                       # Data repositories
├── security/                         # JWT security
└── service/                          # Business logic
```

## 🚀 Deployment

### Development
```bash
# Backend
cd backend && mvn spring-boot:run

# Frontend
cd frontend && flutter run
```

### Production
- **Backend**: Deploy Spring Boot JAR to cloud platform
- **Database**: MongoDB Atlas (already configured)
- **Frontend**: Build APK/AAB for Google Play Store

## 📞 Support & Contribution

For technical support, feature requests, or contributions:
1. Create issues in the project repository
2. Follow coding standards and documentation
3. Test thoroughly before submitting pull requests

## 🏆 Key Achievements

- **Complete full-stack implementation** with modern technologies
- **Beautiful, responsive UI** optimized for rural users
- **Robust authentication system** with multiple options
- **Offline-first approach** with automatic synchronization
- **Comprehensive admin dashboard** for efficient management
- **Real-time notifications** and status tracking
- **Scalable architecture** ready for production deployment

---
*Built with ❤️ for Smart Villages Initiative - Empowering Rural Communities Through Technology*