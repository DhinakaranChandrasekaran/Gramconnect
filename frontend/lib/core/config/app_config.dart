class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // For Android Emulator
  // static const String baseUrl = 'http://localhost:8080/api'; // For iOS Simulator

  static const String appName = 'GramConnect';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String complaintsEndpoint = '/complaints';
  static const String adminEndpoint = '/admin';
  static const String filesEndpoint = '/files';
  static const String aadhaarEndpoint = '/aadhaar';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Notification Settings
  static const String notificationChannelId = 'gramconnect_notifications';
  static const String notificationChannelName = 'GramConnect Notifications';

  // Map Settings
  static const double defaultLatitude = 11.0168; // Tamil Nadu
  static const double defaultLongitude = 76.9558;
  static const double defaultZoom = 15.0;

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxComplaintDescriptionLength = 500;
  static const double maxImageSizeMB = 5.0;

  // Colors
  static const Map<String, String> categoryColors = {
    'GARBAGE': '#FF6B6B',
    'WATER_SUPPLY': '#4ECDC4',
    'ELECTRICITY': '#FFE66D',
    'DRAINAGE': '#95A5A6',
    'ROAD_DAMAGE': '#FF8B42',
    'HEALTH_CENTER': '#74B9FF',
    'TRANSPORT': '#A29BFE',
  };

  // Complaint Categories in Tamil
  static const Map<String, String> categoryTamil = {
    'GARBAGE': 'குப்பை',
    'WATER_SUPPLY': 'நீர் விநியோகம்',
    'ELECTRICITY': 'மின்சாரம்',
    'DRAINAGE': 'வடிகால்',
    'ROAD_DAMAGE': 'சாலை சேதம்',
    'HEALTH_CENTER': 'சுகாதார மையம்',
    'TRANSPORT': 'போக்குவரத்து',
  };
}