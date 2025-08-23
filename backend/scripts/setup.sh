#!/bin/bash

# GramConnect Setup Script
echo "🔶 Setting up GramConnect Full-Stack Application"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Java is installed
check_java() {
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
        print_success "Java found: $JAVA_VERSION"
    else
        print_error "Java not found. Please install Java 21 or higher."
        exit 1
    fi
}

# Check if Flutter is installed
check_flutter() {
    if command -v flutter &> /dev/null; then
        FLUTTER_VERSION=$(flutter --version | head -n 1)
        print_success "Flutter found: $FLUTTER_VERSION"
    else
        print_error "Flutter not found. Please install Flutter 3.32.8 or higher."
        exit 1
    fi
}

# Setup backend
setup_backend() {
    print_status "Setting up backend..."
    
    cd backend
    
    # Make mvnw executable
    chmod +x mvnw
    
    # Install dependencies
    print_status "Installing backend dependencies..."
    ./mvnw clean install -DskipTests
    
    if [ $? -eq 0 ]; then
        print_success "Backend dependencies installed successfully"
    else
        print_error "Failed to install backend dependencies"
        exit 1
    fi
    
    cd ..
}

# Setup frontend
setup_frontend() {
    print_status "Setting up frontend..."
    
    cd frontend
    
    # Get Flutter dependencies
    print_status "Installing frontend dependencies..."
    flutter pub get
    
    if [ $? -eq 0 ]; then
        print_success "Frontend dependencies installed successfully"
    else
        print_error "Failed to install frontend dependencies"
        exit 1
    fi
    
    cd ..
}

# Create environment files
create_env_files() {
    print_status "Creating environment configuration files..."
    
    # Backend environment file
    if [ ! -f "backend/src/main/resources/application-dev.yml" ]; then
        print_status "Creating backend environment file..."
        cat > backend/src/main/resources/application-dev.yml << EOF
spring:
  data:
    mongodb:
      uri: \${MONGODB_URI:mongodb+srv://username:password@cluster.mongodb.net/gramconnect}
  
  mail:
    username: \${GMAIL_USERNAME:your-email@gmail.com}
    password: \${GMAIL_APP_PASSWORD:your-app-password}

jwt:
  secret: \${JWT_SECRET:gramconnect-super-secret-key-for-development-environment-only}
  
app:
  environment: dev

logging:
  level:
    com.gramconnect: DEBUG
    org.springframework.mail: DEBUG
EOF
        print_success "Backend environment file created"
    else
        print_warning "Backend environment file already exists"
    fi
    
    # Frontend environment file
    if [ ! -f "frontend/lib/core/config/env.dart" ]; then
        print_status "Creating frontend environment file..."
        mkdir -p frontend/lib/core/config
        cat > frontend/lib/core/config/env.dart << EOF
class Environment {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:8080/api'; // iOS simulator
  static const bool isDevelopment = true;
  static const String appName = 'GramConnect';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String complaintsEndpoint = '/complaints';
  static const String schedulesEndpoint = '/schedules';
  static const String missedPickupsEndpoint = '/missed-pickups';
  static const String notificationsEndpoint = '/notifications';
  static const String adminsEndpoint = '/admins';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String profileCompletedKey = 'profile_completed';
  
  // OTP Settings
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 5;
  static const int otpResendCooldownSeconds = 60;
  static const int maxOtpAttempts = 3;
  static const int maxOtpResends = 3;
  
  // File Upload Settings
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  
  // Location Settings
  static const double defaultLocationAccuracy = 100.0;
  static const int locationTimeoutSeconds = 30;
  
  // Notification Settings
  static const String notificationChannelId = 'gramconnect_notifications';
  static const String notificationChannelName = 'GramConnect Notifications';
  static const String notificationChannelDescription = 'Notifications for complaint updates and reminders';
}
EOF
        print_success "Frontend environment file created"
    else
        print_warning "Frontend environment file already exists"
    fi
}

# Main setup function
main() {
    echo "🔶 GramConnect Setup Script"
    echo "================================"
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    check_java
    check_flutter
    
    # Setup backend
    setup_backend
    
    # Setup frontend
    setup_frontend
    
    # Create environment files
    create_env_files
    
    echo ""
    echo "================================"
    print_success "🎉 Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Configure your MongoDB Atlas connection in backend/src/main/resources/application-dev.yml"
    echo "2. Set up Gmail SMTP credentials for OTP emails"
    echo "3. Run the backend: cd backend && ./mvnw spring-boot:run"
    echo "4. Seed super admin: curl -X POST http://localhost:8080/api/admins/seed -H \"Content-Type: application/json\" -d '{\"email\":\"admin@gramconnect.com\",\"password\":\"Admin@123\"}'"
    echo "5. Run the frontend: cd frontend && flutter run"
    echo ""
    echo "📖 Check README.md for detailed setup instructions"
    echo "🔶 Happy coding!"
}

# Run main function
main