import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/symptom_tracking/screens/symptom_tracking_screen_new.dart';
import '../../features/nutrition/screens/nutrition_screen.dart';
import '../../features/healthcare_facilities/screens/facility_locator_screen.dart';
import '../../features/expert_content/screens/expert_content_screen.dart';
import '../../features/tokens/screens/token_screen.dart';
import '../../features/milestones/screens/milestone_screen.dart';
import '../../features/health_dashboard/screens/health_dashboard_screen.dart';
import '../../features/community/screens/community_screen.dart';
import '../../features/emergency/screens/emergency_screen.dart';
import '../../features/appointments/screens/appointment_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Feature Routes
          GoRoute(
            path: 'symptoms',
            name: 'symptoms',
            builder: (context, state) => const SymptomTrackingScreen(),
          ),
          
          GoRoute(
            path: 'nutrition',
            name: 'nutrition',
            builder: (context, state) => const NutritionScreen(),
            routes: [
              GoRoute(
                path: 'meal-plan/:id',
                name: 'meal-plan',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return MealPlanDetailScreen(mealPlanId: id);
                },
              ),
              GoRoute(
                path: 'recipe/:id',
                name: 'recipe',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return RecipeDetailScreen(recipeId: id);
                },
              ),
            ],
          ),
          
          GoRoute(
            path: 'facilities',
            name: 'facilities',
            builder: (context, state) => const FacilityLocatorScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                name: 'facility-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return FacilityDetailScreen(facilityId: id);
                },
              ),
            ],
          ),
          
          GoRoute(
            path: 'expert-content',
            name: 'expert-content',
            builder: (context, state) => const ExpertContentScreen(),
            routes: [
              GoRoute(
                path: 'article/:id',
                name: 'article',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ArticleDetailScreen(articleId: id);
                },
              ),
            ],
          ),
          
          GoRoute(
            path: 'tokens',
            name: 'tokens',
            builder: (context, state) => const TokenScreen(),
            routes: [
              // TODO: Implement rewards screen
              // GoRoute(
              //   path: 'rewards',
              //   name: 'rewards',
              //   builder: (context, state) => const RewardsScreen(),
              // ),
            ],
          ),
          
          GoRoute(
            path: 'milestones',
            name: 'milestones',
            builder: (context, state) => const MilestoneScreen(),
            routes: [
              GoRoute(
                path: 'week/:week',
                name: 'milestone-detail',
                builder: (context, state) {
                  final week = int.parse(state.pathParameters['week']!);
                  return MilestoneDetailScreen(week: week);
                },
              ),
            ],
          ),
          
          GoRoute(
            path: 'health-dashboard',
            name: 'health-dashboard',
            builder: (context, state) => const HealthDashboardScreen(),
          ),
          
          GoRoute(
            path: 'community',
            name: 'community',
            builder: (context, state) => const CommunityScreen(),
            routes: [
              GoRoute(
                path: 'post/:id',
                name: 'post-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PostDetailScreen(postId: id);
                },
              ),
              GoRoute(
                path: 'create-post',
                name: 'create-post',
                builder: (context, state) => const CreatePostScreen(),
              ),
            ],
          ),
          
          GoRoute(
            path: 'emergency',
            name: 'emergency',
            builder: (context, state) => const EmergencyScreen(),
          ),
          
          GoRoute(
            path: 'appointments',
            name: 'appointments',
            builder: (context, state) => const AppointmentScreen(),
            routes: [
              GoRoute(
                path: 'book',
                name: 'book-appointment',
                builder: (context, state) => const BookAppointmentScreen(),
              ),
              GoRoute(
                path: 'detail/:id',
                name: 'appointment-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return AppointmentDetailScreen(appointmentId: id);
                },
              ),
            ],
          ),
          
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: 'medical-history',
                name: 'medical-history',
                builder: (context, state) => const MedicalHistoryScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Placeholder screens that will be implemented
class SymptomEntryScreen extends StatelessWidget {
  final String entryId;
  
  const SymptomEntryScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Symptom Entry $entryId')),
      body: const Center(child: Text('Symptom Entry Screen')),
    );
  }
}

class MealPlanDetailScreen extends StatelessWidget {
  final String mealPlanId;
  
  const MealPlanDetailScreen({super.key, required this.mealPlanId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meal Plan $mealPlanId')),
      body: const Center(child: Text('Meal Plan Detail Screen')),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;
  
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipe $recipeId')),
      body: const Center(child: Text('Recipe Detail Screen')),
    );
  }
}

class FacilityDetailScreen extends StatelessWidget {
  final String facilityId;
  
  const FacilityDetailScreen({super.key, required this.facilityId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Facility $facilityId')),
      body: const Center(child: Text('Facility Detail Screen')),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final String articleId;
  
  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Article $articleId')),
      body: const Center(child: Text('Article Detail Screen')),
    );
  }
}

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewards')),
      body: const Center(child: Text('Rewards Screen')),
    );
  }
}

class MilestoneDetailScreen extends StatelessWidget {
  final int week;
  
  const MilestoneDetailScreen({super.key, required this.week});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Week $week Milestone')),
      body: const Center(child: Text('Milestone Detail Screen')),
    );
  }
}

class PostDetailScreen extends StatelessWidget {
  final String postId;
  
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post $postId')),
      body: const Center(child: Text('Post Detail Screen')),
    );
  }
}

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: const Center(child: Text('Create Post Screen')),
    );
  }
}

class BookAppointmentScreen extends StatelessWidget {
  const BookAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: const Center(child: Text('Book Appointment Screen')),
    );
  }
}

class AppointmentDetailScreen extends StatelessWidget {
  final String appointmentId;
  
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Appointment $appointmentId')),
      body: const Center(child: Text('Appointment Detail Screen')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Screen')),
    );
  }
}

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical History')),
      body: const Center(child: Text('Medical History Screen')),
    );
  }
}
