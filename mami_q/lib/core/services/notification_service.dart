import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Notification channels
  static const String generalChannelId = 'general';
  static const String appointmentChannelId = 'appointments';
  static const String emergencyChannelId = 'emergency';
  static const String symptomChannelId = 'symptoms';
  static const String mealChannelId = 'meals';
  static const String milestoneChannelId = 'milestones';

  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Request permissions
    final notificationPermission = await Permission.notification.request();
    if (notificationPermission.isDenied) {
      return;
    }

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Initialize Firebase messaging
    await _initializeFirebaseMessaging();
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  static Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        generalChannelId,
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        appointmentChannelId,
        'Appointment Reminders',
        description: 'Medical appointment reminders',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        emergencyChannelId,
        'Emergency Alerts',
        description: 'Emergency alerts and warnings',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        symptomChannelId,
        'Symptom Reminders',
        description: 'Daily symptom tracking reminders',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        mealChannelId,
        'Meal Reminders',
        description: 'Meal planning and nutrition reminders',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        milestoneChannelId,
        'Milestone Notifications',
        description: 'Pregnancy milestone achievements',
        importance: Importance.high,
      ),
    ];

    for (final channel in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  static Future<void> _initializeFirebaseMessaging() async {
    // Request permission for iOS
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  static void _onNotificationTapped(NotificationResponse details) {
    final payload = details.payload;
    if (payload != null) {
      _handleNotificationNavigation(payload);
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await showLocalNotification(
        id: message.hashCode,
        title: notification.title ?? '',
        body: notification.body ?? '',
        channelId: _getChannelIdFromType(message.data['type']),
        payload: message.data.toString(),
      );
    }
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    _handleNotificationNavigation(message.data.toString());
  }

  static String _getChannelIdFromType(String? type) {
    switch (type) {
      case 'appointment':
        return appointmentChannelId;
      case 'emergency':
        return emergencyChannelId;
      case 'symptom':
        return symptomChannelId;
      case 'meal':
        return mealChannelId;
      case 'milestone':
        return milestoneChannelId;
      default:
        return generalChannelId;
    }
  }

  static void _handleNotificationNavigation(String payload) {
    // TODO: Implement navigation based on payload
    // This will be implemented with go_router navigation
    print('Navigate to: $payload');
  }

  // Public methods for scheduling notifications
  
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String channelId = generalChannelId,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getImportance(channelId),
      priority: Priority.defaultPriority,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String channelId = generalChannelId,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getImportance(channelId),
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }
  static Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String channelId = generalChannelId,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getImportance(channelId),
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.daily,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Daily reminder notifications
  static Future<void> scheduleDailySymptomReminder() async {
    await scheduleRepeatingNotification(
      id: 1001,
      title: 'Daily Symptom Check',
      body: 'How are you feeling today? Log your symptoms to track your health.',
      time: const TimeOfDay(hour: 9, minute: 0), // 9:00 AM
      channelId: symptomChannelId,
      payload: 'navigate:symptoms',
    );
  }
  static Future<void> scheduleMealReminders() async {
    final mealTimes = [
      {'time': const TimeOfDay(hour: 8, minute: 0), 'meal': 'breakfast'},
      {'time': const TimeOfDay(hour: 13, minute: 0), 'meal': 'lunch'},
      {'time': const TimeOfDay(hour: 19, minute: 0), 'meal': 'dinner'},
    ];
    

    for (int i = 0; i < mealTimes.length; i++) {
      final meal = mealTimes[i];
      await scheduleRepeatingNotification(
        id: 2001 + i,
        title: 'Meal Time!',
        body: 'Time for your ${meal['meal']}. Check your meal plan for healthy options.',
        time: meal['time'] as TimeOfDay,
        channelId: mealChannelId,
        payload: 'navigate:nutrition',
      );
    }
  }

  static Future<void> scheduleAppointmentReminder({
    required int appointmentId,
    required String title,
    required DateTime appointmentTime,
    String? doctorName,
  }) async {
    // Reminder 24 hours before
    final dayBefore = appointmentTime.subtract(const Duration(days: 1));
    await scheduleNotification(
      id: 3000 + appointmentId,
      title: 'Appointment Tomorrow',
      body: 'You have an appointment tomorrow at ${_formatTime(appointmentTime)}${doctorName != null ? ' with Dr. $doctorName' : ''}',
      scheduledTime: dayBefore,
      channelId: appointmentChannelId,
      payload: 'navigate:appointments:$appointmentId',
    );

    // Reminder 1 hour before
    final hourBefore = appointmentTime.subtract(const Duration(hours: 1));
    await scheduleNotification(
      id: 3100 + appointmentId,
      title: 'Appointment in 1 Hour',
      body: 'Your appointment is starting soon. Don\'t forget to bring your documents!',
      scheduledTime: hourBefore,
      channelId: appointmentChannelId,
      payload: 'navigate:appointments:$appointmentId',
    );
  }

  static Future<void> showEmergencyAlert({
    required String title,
    required String body,
    String? payload,
  }) async {
    await showLocalNotification(
      id: 9999,
      title: title,
      body: body,
      channelId: emergencyChannelId,
      payload: payload ?? 'navigate:emergency',
    );
  }

  static Future<void> showMilestoneNotification({
    required int week,
    required String milestone,
  }) async {
    await showLocalNotification(
      id: 4000 + week,
      title: 'Pregnancy Milestone! 🎉',
      body: 'Week $week: $milestone',
      channelId: milestoneChannelId,
      payload: 'navigate:milestones:$week',
    );
  }

  // Helper methods
  static String _getChannelName(String channelId) {
    switch (channelId) {
      case appointmentChannelId:
        return 'Appointment Reminders';
      case emergencyChannelId:
        return 'Emergency Alerts';
      case symptomChannelId:
        return 'Symptom Reminders';
      case mealChannelId:
        return 'Meal Reminders';
      case milestoneChannelId:
        return 'Milestone Notifications';
      default:
        return 'General Notifications';
    }
  }

  static String _getChannelDescription(String channelId) {
    switch (channelId) {
      case appointmentChannelId:
        return 'Medical appointment reminders';
      case emergencyChannelId:
        return 'Emergency alerts and warnings';
      case symptomChannelId:
        return 'Daily symptom tracking reminders';
      case mealChannelId:
        return 'Meal planning and nutrition reminders';
      case milestoneChannelId:
        return 'Pregnancy milestone achievements';
      default:
        return 'General app notifications';
    }
  }

  static Importance _getImportance(String channelId) {
    switch (channelId) {
      case emergencyChannelId:
        return Importance.max;
      case appointmentChannelId:
      case milestoneChannelId:
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Get FCM token for server registration
  static Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Subscribe to topic for targeted notifications
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print('Handling a background message: ${message.messageId}');
}
