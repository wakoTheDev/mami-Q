class AppConstants {
  // App Information
  static const String appName = 'MamiQ';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Comprehensive Prenatal Care Application';
  
  // API Configuration
  static const String baseUrl = 'https://api.mamiq.com';
  static const String apiVersion = 'v1';
  
  // Database Configuration
  static const String databaseName = 'mami_q_db';
  static const int databaseVersion = 1;
  
  // Hive Box Names
  static const String userBox = 'user_box';
  static const String symptomBox = 'symptom_box';
  static const String mealPlanBox = 'meal_plan_box';
  static const String appointmentBox = 'appointment_box';
  static const String tokenBox = 'token_box';
  static const String healthMetricsBox = 'health_metrics_box';
  static const String milestoneBox = 'milestone_box';
  static const String facilityBox = 'facility_box';
  static const String contentBox = 'content_box';
  static const String communityBox = 'community_box';
  static const String emergencyBox = 'emergency_box';
  
  // Pregnancy Constants
  static const int totalPregnancyWeeks = 40;
  static const int firstTrimesterEnd = 12;
  static const int secondTrimesterEnd = 27;
  static const int thirdTrimesterEnd = 40;
  
  // Token System
  static const int dailySymptomTokens = 5;
  static const int mealPrepTokens = 10;
  static const int exerciseTokens = 15;
  static const int appointmentTokens = 20;
  static const int communityPostTokens = 3;
  static const int referralTokens = 50;
  
  // Notification Channels
  static const String generalNotificationChannel = 'general';
  static const String appointmentNotificationChannel = 'appointments';
  static const String emergencyNotificationChannel = 'emergency';
  static const String symptomNotificationChannel = 'symptoms';
  static const String mealNotificationChannel = 'meals';
  
  // Shared Preferences Keys
  static const String isFirstTimeUser = 'is_first_time_user';
  static const String userId = 'user_id';
  static const String pregnancyStartDate = 'pregnancy_start_date';
  static const String lastSymptomDate = 'last_symptom_date';
  static const String notificationEnabled = 'notification_enabled';
  static const String locationPermissionGranted = 'location_permission_granted';
  
  // File Paths
  static const String profileImagePath = 'profile_images';
  static const String symptomImagePath = 'symptom_images';
  static const String mealImagePath = 'meal_images';
  static const String milestoneImagePath = 'milestone_images';
  static const String documentPath = 'documents';
  
  // Emergency Contacts Limit
  static const int maxEmergencyContacts = 5;
  
  // Community Guidelines
  static const int maxPostLength = 500;
  static const int maxCommentLength = 200;
  static const int maxImagesPerPost = 3;
  
  // Health Metrics Ranges
  static const double minPregnancyWeight = 30.0;
  static const double maxPregnancyWeight = 200.0;
  static const int minHeartRate = 40;
  static const int maxHeartRate = 200;
  static const double minBloodPressureSystolic = 70.0;
  static const double maxBloodPressureSystolic = 200.0;
  static const double minBloodPressureDiastolic = 40.0;
  static const double maxBloodPressureDiastolic = 130.0;
  
  // Map Configuration
  static const double defaultMapZoom = 14.0;
  static const double facilitySearchRadius = 50000.0; // 50km in meters
  
  // Offline Support
  static const int maxOfflineSymptomEntries = 100;
  static const int maxOfflineMealPlans = 50;
  static const int maxOfflineContent = 20;
  
  // Symptom Categories
  static const List<String> symptomCategories = [
    'Physical',
    'Emotional',
    'Digestive',
    'Sleep',
    'Energy',
    'Pain',
    'Movement',
    'Other'
  ];
}
