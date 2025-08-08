import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/nutrition_provider.dart';
import '../models/meal_plan.dart';
import 'widgets/meal_plan_card.dart';
import 'widgets/shopping_list_tab.dart';
import 'widgets/nutrition_tracker_tab.dart';
import 'widgets/add_meal_dialog.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition & Meals'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant), text: 'Meal Plans'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'Shopping'),
            Tab(icon: Icon(Icons.analytics), text: 'Nutrition'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MealPlansTab(),
          ShoppingListTab(),
          NutritionTrackerTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => _showAddMealDialog(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showAddMealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddMealDialog(),
    );
  }
}

class MealPlansTab extends ConsumerWidget {
  const MealPlansTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(mealPlansProvider);
    final currentTrimester = ref.watch(currentTrimesterProvider);
    final selectedMealType = ref.watch(selectedMealTypeProvider);

    return Column(
      children: [
        // Filter section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by Trimester & Meal Type',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: currentTrimester,
                      decoration: const InputDecoration(
                        labelText: 'Trimester',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [1, 2, 3].map((trimester) {
                        return DropdownMenuItem(
                          value: trimester,
                          child: Text('Trimester $trimester'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(currentTrimesterProvider.notifier).state = value;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: selectedMealType,
                      decoration: const InputDecoration(
                        labelText: 'Meal Type',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All')),
                        ...['breakfast', 'lunch', 'dinner', 'snack'].map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.toUpperCase()),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        ref.read(selectedMealTypeProvider.notifier).state = value;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Meals list
        Expanded(
          child: mealsAsync.when(
            data: (meals) {
              List<MealPlan> filteredMeals = meals;
              
              // Filter by trimester
              filteredMeals = filteredMeals
                  .where((meal) => meal.trimester == currentTrimester)
                  .toList();
              
              // Filter by meal type if selected
              if (selectedMealType != null) {
                filteredMeals = filteredMeals
                    .where((meal) => meal.mealType == selectedMealType)
                    .toList();
              }
              
              if (filteredMeals.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No meal plans found',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first meal plan to get started',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredMeals.length,
                itemBuilder: (context, index) {
                  final meal = filteredMeals[index];
                  return MealPlanCard(
                    meal: meal,
                    onTap: () => _viewMealDetails(context, meal),
                    onFavoriteToggle: () => _toggleFavorite(ref, meal.id),
                    onAddToShopping: () => _addToShoppingList(ref, meal),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading meal plans',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(mealPlansProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _viewMealDetails(BuildContext context, MealPlan meal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MealDetailScreen(meal: meal),
      ),
    );
  }

  void _toggleFavorite(WidgetRef ref, String mealId) {
    ref.read(mealPlansProvider.notifier).toggleFavorite(mealId);
  }

  void _addToShoppingList(WidgetRef ref, MealPlan meal) {
    ref.read(shoppingListProvider.notifier).addMealToShoppingList(meal);
    
    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(
        content: Text('${meal.recipeName} ingredients added to shopping list'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class MealDetailScreen extends StatelessWidget {
  final MealPlan meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.recipeName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Chip(
                          label: Text('Trimester ${meal.trimester}'),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(meal.mealType.toUpperCase()),
                          backgroundColor: AppColors.secondary.withOpacity(0.1),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(meal.difficulty.toUpperCase()),
                          backgroundColor: _getDifficultyColor(meal.difficulty),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${meal.preparationTime} min'),
                        const SizedBox(width: 16),
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${meal.servings} servings'),
                        const SizedBox(width: 16),
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(meal.rating.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Ingredients
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ingredients', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 12),
                    ...meal.ingredients.map((ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.fiber_manual_record, size: 8, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(child: Text(ingredient)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Nutritional info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nutritional Information', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: meal.nutritionalInfo.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: AppTextStyles.caption,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Cooking instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cooking Instructions', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 12),
                    Text(
                      meal.cookingInstructions,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            // Allergens
            if (meal.allergens.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange[600]),
                          const SizedBox(width: 8),
                          Text('Allergens', style: AppTextStyles.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: meal.allergens.map((allergen) {
                          return Chip(
                            label: Text(allergen),
                            backgroundColor: Colors.orange[100],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green.withOpacity(0.1);
      case 'medium':
        return Colors.orange.withOpacity(0.1);
      case 'hard':
        return Colors.red.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }
}
