import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/meal_plan.dart';
import '../providers/nutrition_provider.dart';

class MealPlanDetailScreen extends ConsumerWidget {
  final String mealPlanId;
  
  const MealPlanDetailScreen({
    super.key, 
    required this.mealPlanId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlansAsync = ref.watch(mealPlansProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Plan Details', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: mealPlansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading meal plan: $error',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
          ),
        ),
        data: (mealPlans) {
          final mealPlan = mealPlans.firstWhere(
            (plan) => plan.id == mealPlanId,
            orElse: () => MealPlan(
              id: 'not-found',
              name: 'Not Found',
              description: 'The requested meal plan could not be found',
              meals: const [],
              nutritionSummary: const NutritionSummary(
                calories: 0,
                protein: 0,
                carbs: 0,
                fat: 0,
                fiber: 0,
              ),
              weekDay: null,
              trimester: 1,
              mealType: 'Default',
              recipeName: '',
              ingredients: const [],
              nutritionalInfo: const {'calories': '0', 'protein': '0g'},
              cookingInstructions: '',
              images: const [],
              culturalContext: '',
              preparationTime: 0,
              difficulty: 'Easy',
              allergens: const [],
              servings: 1,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          
          if (mealPlan.id == 'not-found') {
            return Center(
              child: Text(
                'Meal plan not found',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.error),
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealPlan.name,
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  mealPlan.description,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 24),
                
                // Nutrition Summary Card
                _buildNutritionSummaryCard(mealPlan),
                const SizedBox(height: 24),
                
                // Meals List
                Text(
                  'Meals',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 16),
                ...mealPlan.meals.map((meal) => _buildMealCard(context, meal)),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildNutritionSummaryCard(MealPlan mealPlan) {
    final summary = mealPlan.nutritionSummary;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Summary',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            _buildNutrientRow('Calories', '${summary.calories} kcal', AppColors.primary),
            const SizedBox(height: 8),
            _buildNutrientRow('Protein', '${summary.protein}g', AppColors.secondary),
            const SizedBox(height: 8),
            _buildNutrientRow('Carbs', '${summary.carbs}g', AppColors.accent),
            const SizedBox(height: 8),
            _buildNutrientRow('Fat', '${summary.fat}g', AppColors.warning),
            const SizedBox(height: 8),
            _buildNutrientRow('Fiber', '${summary.fiber}g', AppColors.info),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNutrientRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  
  Widget _buildMealCard(BuildContext context, Meal meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  meal.name,
                  style: AppTextStyles.titleMedium,
                ),
                Text(
                  meal.timeOfDay,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Foods:',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...meal.foods.map(
              (food) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $food',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (meal.recipe != null) ...[
              const Divider(),
              TextButton(
                onPressed: () {
                  // Navigate to recipe screen
                  // context.push('/nutrition/recipe/${meal.recipe!.id}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recipe feature coming soon!'))
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Recipe',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
