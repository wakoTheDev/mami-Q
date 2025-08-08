import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/recipe.dart';
import '../providers/nutrition_provider.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;
  
  const RecipeDetailScreen({
    super.key, 
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Details', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading recipe: $error',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
          ),
        ),
        data: (recipes) {
          final recipe = recipes.firstWhere(
            (r) => r.id == recipeId,
            orElse: () => Recipe(
              id: 'not-found',
              name: 'Not Found',
              description: 'The requested recipe could not be found',
              ingredients: const [],
              steps: const [],
              imageUrl: null,
              prepTime: 0,
              cookTime: 0,
              servings: 0,
              nutrition: const NutritionInfo(
                calories: 0,
                protein: 0,
                carbs: 0,
                fat: 0,
                fiber: 0,
              ),
              tags: const [],
            ),
          );
          
          if (recipe.id == 'not-found') {
            return Center(
              child: Text(
                'Recipe not found',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.error),
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 200,
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 48, color: AppColors.textTertiary),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                
                Text(
                  recipe.name,
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 8),
                
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recipe.tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                    side: BorderSide.none,
                    padding: const EdgeInsets.all(0),
                    labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                
                Text(
                  recipe.description,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 24),
                
                // Recipe Info
                _buildRecipeInfoRow(recipe),
                const SizedBox(height: 24),
                
                // Nutrition
                _buildNutritionInfo(recipe),
                const SizedBox(height: 24),
                
                // Ingredients
                Text(
                  'Ingredients',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 12),
                ...recipe.ingredients.map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: AppTextStyles.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Steps
                Text(
                  'Instructions',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  recipe.steps.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            recipe.steps[index],
                            style: AppTextStyles.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRecipeInfoRow(Recipe recipe) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoItem('Prep Time', '${recipe.prepTime} min', Icons.access_time),
        _buildInfoItem('Cook Time', '${recipe.cookTime} min', Icons.whatshot),
        _buildInfoItem('Servings', '${recipe.servings}', Icons.people),
      ],
    );
  }
  
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
  
  Widget _buildNutritionInfo(Recipe recipe) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Information',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNutrientItem('Calories', '${recipe.nutrition.calories} kcal'),
                _buildNutrientItem('Protein', '${recipe.nutrition.protein}g'),
                _buildNutrientItem('Carbs', '${recipe.nutrition.carbs}g'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNutrientItem('Fat', '${recipe.nutrition.fat}g'),
                _buildNutrientItem('Fiber', '${recipe.nutrition.fiber}g'),
                const SizedBox(width: 80), // For alignment
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNutrientItem(String label, String value) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
