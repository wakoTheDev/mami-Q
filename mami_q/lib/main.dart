import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_text_styles.dart';
import 'core/routing/app_router.dart';
import 'features/symptom_tracking/repositories/symptom_tracking_repository.dart';
import 'features/symptom_tracking/providers/symptom_tracking_provider_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase with the generated options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Handle gracefully if Firebase is not configured yet
    debugPrint('Firebase initialization failed: $e');
  }
  
  // Initialize repositories
  final symptomRepo = await LocalSymptomTrackingRepository.getInstance();
  final sharedPrefs = await SharedPreferences.getInstance();
  
  // Check if first launch for onboarding
  final isFirstLaunch = sharedPrefs.getBool('isFirstLaunch') ?? true;
  if (isFirstLaunch) {
    await sharedPrefs.setBool('isFirstLaunch', false);
  }
  
  runApp(
    ProviderScope(
      overrides: [
        // Override providers with initialized instances
        symptomRepositoryProvider.overrideWithValue(symptomRepo),
      ],
      child: MainApp(
        isFirstLaunch: isFirstLaunch,
      ),
    )
  );
}

class MainApp extends ConsumerWidget {
  final bool isFirstLaunch;
  
  const MainApp({
    super.key,
    required this.isFirstLaunch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the router from the provider
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'MamiQ - Prenatal Care',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          displaySmall: AppTextStyles.displaySmall,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineMedium: AppTextStyles.headlineMedium,
          headlineSmall: AppTextStyles.headlineSmall,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          titleSmall: AppTextStyles.titleSmall,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
        ),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.surface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'MamiQ Dashboard',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            _buildPregnancyProgress(),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildTodaysReminders(),
            const SizedBox(height: 24),
            _buildHealthMetrics(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning, Sarah! 👋',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re doing great! Keep taking care of yourself and your baby.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyProgress() {
    const currentWeek = 24;
    const totalWeeks = 40;
    const trimester = 2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pregnancy Progress',
                style: AppTextStyles.titleMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondTrimester,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Trimester $trimester',
                  style: AppTextStyles.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '$currentWeek',
                style: AppTextStyles.pregnancyWeek,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'weeks',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
                  ),
                  Text(
                    'out of $totalWeeks',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: currentWeek / totalWeeks,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            '${(currentWeek / totalWeeks * 100).round()}% complete',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'title': 'Log Symptoms',
        'icon': Icons.assignment_outlined,
        'color': AppColors.primary,
        'onTap': () => _navigateToSymptoms(context),
      },
      {
        'title': 'Meal Planning',
        'icon': Icons.restaurant_outlined,
        'color': AppColors.secondary,
        'onTap': () => _navigateToNutrition(context),
      },
      {
        'title': 'Find Facilities',
        'icon': Icons.local_hospital_outlined,
        'color': AppColors.accent,
        'onTap': () => _navigateToFacilities(context),
      },
      {
        'title': 'Emergency',
        'icon': Icons.emergency_outlined,
        'color': AppColors.error,
        'onTap': () => _showEmergencyDialog(context),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return GestureDetector(
              onTap: action['onTap'] as VoidCallback,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (action['color'] as Color).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      size: 32,
                      color: action['color'] as Color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['title'] as String,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: action['color'] as Color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTodaysReminders() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Reminders',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildReminderItem(
            'Take prenatal vitamins',
            '9:00 AM',
            Icons.medication_outlined,
            AppColors.warning,
          ),
          const SizedBox(height: 12),
          _buildReminderItem(
            'Drink 8 glasses of water',
            'Throughout the day',
            Icons.water_drop_outlined,
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildReminderItem(
            'Doctor appointment',
            '2:00 PM',
            Icons.local_hospital_outlined,
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium),
              Text(time, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: AppColors.textTertiary),
      ],
    );
  }

  Widget _buildHealthMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Overview',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Weight',
                  '68.5 kg',
                  '+0.5 kg',
                  Icons.monitor_weight_outlined,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Blood Pressure',
                  '120/80',
                  'Normal',
                  Icons.favorite_outline,
                  AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                change,
                style: AppTextStyles.labelSmall.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(color: color),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  void _navigateToSymptoms(BuildContext context) {
    // TODO: Navigate to symptom tracking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Symptom tracking feature coming soon!')),
    );
  }

  void _navigateToNutrition(BuildContext context) {
    // TODO: Navigate to nutrition
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nutrition feature coming soon!')),
    );
  }

  void _navigateToFacilities(BuildContext context) {
    // TODO: Navigate to facilities
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Healthcare facilities feature coming soon!')),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Contacts'),
        content: const Text('Emergency contact feature will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Placeholder screens
class SymptomTrackingPlaceholder extends StatelessWidget {
  const SymptomTrackingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Symptom Tracking')),
      body: const Center(
        child: Text('Symptom Tracking Screen - Under Development'),
      ),
    );
  }
}

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition & Meal Planning')),
      body: const Center(
        child: Text('Nutrition Screen - Under Development'),
      ),
    );
  }
}

class HealthcareFacilitiesScreen extends StatelessWidget {
  const HealthcareFacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Healthcare Facilities')),
      body: const Center(
        child: Text('Healthcare Facilities Screen - Under Development'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text('Profile Screen - Under Development'),
      ),
    );
  }
}
