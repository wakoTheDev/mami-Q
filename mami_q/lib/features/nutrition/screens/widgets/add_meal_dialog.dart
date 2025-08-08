import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../models/meal_plan.dart';
import '../../providers/nutrition_provider.dart';

class AddMealDialog extends ConsumerStatefulWidget {
  final MealPlan? mealToEdit;
  
  const AddMealDialog({
    super.key,
    this.mealToEdit,
  });

  @override
  ConsumerState<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends ConsumerState<AddMealDialog> {
  final _formKey = GlobalKey<FormState>();
  final _recipeNameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _cookingInstructionsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _servingsController = TextEditingController();
  final _prepTimeController = TextEditingController();
  
  int _selectedTrimester = 1;
  String _selectedMealType = 'breakfast';
  String _selectedDifficulty = 'easy';
  String _selectedCulturalContext = 'West Africa';
  List<String> _selectedAllergens = [];
  
  final List<String> _allergenOptions = [
    'Dairy', 'Gluten', 'Nuts', 'Eggs', 'Soy', 'Fish', 'Shellfish'
  ];

  @override
  void initState() {
    super.initState();
    
    // If editing an existing meal, populate the form
    if (widget.mealToEdit != null) {
      final meal = widget.mealToEdit!;
      _recipeNameController.text = meal.recipeName;
      _ingredientsController.text = meal.ingredients.join('\n');
      _cookingInstructionsController.text = meal.cookingInstructions;
      _caloriesController.text = meal.nutritionalInfo['Calories'] ?? '0';
      _proteinController.text = meal.nutritionalInfo['Protein'] ?? '0';
      _carbsController.text = meal.nutritionalInfo['Carbs'] ?? '0';
      _fatController.text = meal.nutritionalInfo['Fat'] ?? '0';
      _servingsController.text = meal.servings.toString();
      _prepTimeController.text = meal.preparationTime.toString();
      
      _selectedTrimester = meal.trimester;
      _selectedMealType = meal.mealType;
      _selectedDifficulty = meal.difficulty;
      _selectedCulturalContext = meal.culturalContext;
      _selectedAllergens = [...meal.allergens];
    } else {
      _servingsController.text = '4';
      _prepTimeController.text = '30';
    }
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _ingredientsController.dispose();
    _cookingInstructionsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.mealToEdit != null;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog title
                Center(
                  child: Text(
                    isEditing ? 'Edit Meal Plan' : 'Add New Meal Plan',
                    style: AppTextStyles.displaySmall,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Basic meal information
                TextFormField(
                  controller: _recipeNameController,
                  decoration: const InputDecoration(
                    labelText: 'Recipe Name',
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a recipe name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Meal type dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Meal Type',
                    prefixIcon: Icon(Icons.category),
                  ),
                  value: _selectedMealType,
                  items: [
                    for (final type in ['breakfast', 'lunch', 'dinner', 'snack', 'drink'])
                      DropdownMenuItem(
                        value: type,
                        child: Text(type[0].toUpperCase() + type.substring(1)),
                      )
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMealType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Trimester selection chips
                Text('Recommended Trimester', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (int i = 1; i <= 3; i++)
                      ChoiceChip(
                        label: Text('Trimester $i'),
                        selected: _selectedTrimester == i,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedTrimester = i;
                            });
                          }
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _selectedTrimester == i ? Colors.white : Colors.black,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Ingredients
                TextFormField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredients (one per line)',
                    prefixIcon: Icon(Icons.list),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter at least one ingredient';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                
                // Cooking instructions
                TextFormField(
                  controller: _cookingInstructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Cooking Instructions',
                    prefixIcon: Icon(Icons.menu_book),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter cooking instructions';
                    }
                    return null;
                  },
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                // Nutritional info section
                Text('Nutritional Information', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _caloriesController,
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          suffixText: 'kcal',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _proteinController,
                        decoration: const InputDecoration(
                          labelText: 'Protein',
                          suffixText: 'g',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _carbsController,
                        decoration: const InputDecoration(
                          labelText: 'Carbs',
                          suffixText: 'g',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _fatController,
                        decoration: const InputDecoration(
                          labelText: 'Fat',
                          suffixText: 'g',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Additional details
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _servingsController,
                        decoration: const InputDecoration(
                          labelText: 'Servings',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _prepTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Prep Time',
                          suffixText: 'min',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Difficulty level
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Difficulty',
                    prefixIcon: Icon(Icons.timeline),
                  ),
                  value: _selectedDifficulty,
                  items: [
                    for (final diff in ['easy', 'medium', 'hard'])
                      DropdownMenuItem(
                        value: diff,
                        child: Text(diff[0].toUpperCase() + diff.substring(1)),
                      )
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDifficulty = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Cultural context
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Cultural Context',
                    prefixIcon: Icon(Icons.public),
                  ),
                  value: _selectedCulturalContext,
                  items: [
                    for (final region in LocalAfricanCuisine.cuisineByRegion.keys)
                      DropdownMenuItem(
                        value: region,
                        child: Text(region),
                      )
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCulturalContext = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Allergens
                Text('Allergens', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allergenOptions.map((allergen) {
                    return FilterChip(
                      label: Text(allergen),
                      selected: _selectedAllergens.contains(allergen),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedAllergens.add(allergen);
                          } else {
                            _selectedAllergens.remove(allergen);
                          }
                        });
                      },
                      selectedColor: AppColors.secondary,
                      checkmarkColor: Colors.white,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveMeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text(
                        isEditing ? 'Update' : 'Add Meal',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _saveMeal() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    // Prepare nutritional info
    final nutritionalInfo = {
      'Calories': _caloriesController.text,
      'Protein': _proteinController.text,
      'Carbs': _carbsController.text,
      'Fat': _fatController.text,
    };
    
    // Parse ingredients
    final ingredients = _ingredientsController.text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    
    // Create or update meal plan
    final mealPlan = widget.mealToEdit?.copyWith(
      recipeName: _recipeNameController.text,
      trimester: _selectedTrimester,
      mealType: _selectedMealType,
      ingredients: ingredients,
      nutritionalInfo: nutritionalInfo,
      cookingInstructions: _cookingInstructionsController.text,
      culturalContext: _selectedCulturalContext,
      preparationTime: int.tryParse(_prepTimeController.text) ?? 30,
      difficulty: _selectedDifficulty,
      allergens: _selectedAllergens,
      servings: int.tryParse(_servingsController.text) ?? 4,
      updatedAt: DateTime.now(),
    ) ?? MealPlan(
      id: const Uuid().v4(),
      recipeName: _recipeNameController.text,
      trimester: _selectedTrimester,
      mealType: _selectedMealType,
      ingredients: ingredients,
      nutritionalInfo: nutritionalInfo,
      cookingInstructions: _cookingInstructionsController.text,
      images: const [], // No image upload in this version
      culturalContext: _selectedCulturalContext,
      preparationTime: int.tryParse(_prepTimeController.text) ?? 30,
      difficulty: _selectedDifficulty,
      allergens: _selectedAllergens,
      servings: int.tryParse(_servingsController.text) ?? 4,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save the meal plan
    if (widget.mealToEdit != null) {
      ref.read(mealPlansProvider.notifier).updateMealPlan(mealPlan);
    } else {
      ref.read(mealPlansProvider.notifier).addMealPlan(mealPlan);
    }
    
    Navigator.of(context).pop();
  }
}
