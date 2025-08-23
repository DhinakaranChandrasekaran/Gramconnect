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