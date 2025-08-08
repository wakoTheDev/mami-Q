import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/meal_plan.dart' hide Recipe;
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import '../repositories/nutrition_repository.dart';

// Repository provider
final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository();
});

// Meal plans provider
final mealPlansProvider = AsyncNotifierProvider<MealPlansNotifier, List<MealPlan>>(
  () => MealPlansNotifier(),
);

// Recipes provider
final recipesProvider = AsyncNotifierProvider<RecipesNotifier, List<Recipe>>(
  () => RecipesNotifier(),
);

class RecipesNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() async {
    final repository = ref.watch(nutritionRepositoryProvider);
    return await repository.getRecipes();
  }

  Future<void> addRecipe(Recipe recipe) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.saveRecipe(recipe);
      
      // Refresh the list
      final updatedRecipes = await repository.getRecipes();
      state = AsyncValue.data(updatedRecipes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.saveRecipe(recipe);
      
      // Refresh the list
      final updatedRecipes = await repository.getRecipes();
      state = AsyncValue.data(updatedRecipes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.deleteRecipe(recipeId);
      
      // Refresh the list
      final updatedRecipes = await repository.getRecipes();
      state = AsyncValue.data(updatedRecipes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class MealPlansNotifier extends AsyncNotifier<List<MealPlan>> {
  @override
  Future<List<MealPlan>> build() async {
    final repository = ref.watch(nutritionRepositoryProvider);
    return await repository.getMealPlans();
  }

  Future<void> addMealPlan(MealPlan mealPlan) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.saveMealPlan(mealPlan);
      
      // Refresh the list
      final updatedMeals = await repository.getMealPlans();
      state = AsyncValue.data(updatedMeals);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateMealPlan(MealPlan mealPlan) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.saveMealPlan(mealPlan);
      
      // Refresh the list
      final updatedMeals = await repository.getMealPlans();
      state = AsyncValue.data(updatedMeals);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteMealPlan(String mealPlanId) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.deleteMealPlan(mealPlanId);
      
      // Refresh the list
      final updatedMeals = await repository.getMealPlans();
      state = AsyncValue.data(updatedMeals);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleFavorite(String mealPlanId) async {
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.toggleFavoriteMeal(mealPlanId);
      
      // Update the current state without full reload
      state = state.whenData((meals) {
        return meals.map((meal) {
          if (meal.id == mealPlanId) {
            return meal.copyWith(isFavorite: !meal.isFavorite);
          }
          return meal;
        }).toList();
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Filtered meal providers
final mealsByTrimesterProvider = Provider.family<AsyncValue<List<MealPlan>>, int>((ref, trimester) {
  final mealsAsync = ref.watch(mealPlansProvider);
  return mealsAsync.whenData((meals) {
    return meals.where((meal) => meal.trimester == trimester).toList();
  });
});

final mealsByTypeProvider = Provider.family<AsyncValue<List<MealPlan>>, String>((ref, mealType) {
  final mealsAsync = ref.watch(mealPlansProvider);
  return mealsAsync.whenData((meals) {
    return meals.where((meal) => meal.mealType == mealType).toList();
  });
});

// Favorite meals provider
final favoriteMealsProvider = AsyncNotifierProvider<FavoriteMealsNotifier, List<MealPlan>>(
  () => FavoriteMealsNotifier(),
);

// Nutrition progress provider
final nutritionProgressProvider = Provider.family<AsyncValue<Map<String, double>>, int>((ref, trimester) {
  final mealsAsync = ref.watch(mealPlansProvider);
  
  return mealsAsync.whenData((meals) {
    // Get requirements for the specified trimester
    final requirements = PregnancyNutrition.getRequirementsForTrimester(trimester);
    
    // Initialize a map to track the nutritional progress
    final Map<String, double> progress = {};
    for (final req in requirements) {
      progress[req.nutrient] = 0.0;
    }
    
    // Calculate nutrition based on today's planned meals
    final today = DateTime.now();
    final todaysMeals = meals.where((meal) => 
      meal.trimester == trimester &&
      meal.createdAt.year == today.year && 
      meal.createdAt.month == today.month && 
      meal.createdAt.day == today.day
    ).toList();
    
    // Sum up nutritional values
    for (final meal in todaysMeals) {
      for (final nutrient in meal.nutritionalInfo.keys) {
        final value = double.tryParse(meal.nutritionalInfo[nutrient] ?? '0') ?? 0.0;
        
        // Map the nutrient names to our standard names
        switch (nutrient.toLowerCase()) {
          case 'protein':
            progress['Protein'] = (progress['Protein'] ?? 0.0) + value;
            break;
          case 'iron':
            progress['Iron'] = (progress['Iron'] ?? 0.0) + value;
            break;
          case 'calcium':
            progress['Calcium'] = (progress['Calcium'] ?? 0.0) + value;
            break;
          case 'folic acid':
          case 'folate':
            progress['Folic Acid'] = (progress['Folic Acid'] ?? 0.0) + value;
            break;
          case 'vitamin d':
            progress['Vitamin D'] = (progress['Vitamin D'] ?? 0.0) + value;
            break;
          // Add more nutrient mappings as needed
        }
      }
    }
    
    return progress;
  });
});

class FavoriteMealsNotifier extends AsyncNotifier<List<MealPlan>> {
  @override
  Future<List<MealPlan>> build() async {
    final repository = ref.watch(nutritionRepositoryProvider);
    return await repository.getFavoriteMeals();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      final favorites = await repository.getFavoriteMeals();
      state = AsyncValue.data(favorites);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Shopping list provider
final shoppingListProvider = AsyncNotifierProvider<ShoppingListNotifier, List<ShoppingItem>>(
  () => ShoppingListNotifier(),
);

class ShoppingListNotifier extends AsyncNotifier<List<ShoppingItem>> {
  @override
  Future<List<ShoppingItem>> build() async {
    final repository = ref.watch(nutritionRepositoryProvider);
    return await repository.getShoppingList();
  }

  Future<void> addItem(ShoppingItem item) async {
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.addToShoppingList(item);
      
      // Add to current state
      state = state.whenData((items) => [...items, item]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> toggleItemChecked(String itemId, bool isChecked) async {
    try {
      state = state.whenData((items) {
        return items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(isChecked: isChecked);
          }
          return item;
        }).toList();
      });
      
      // Persist changes
      final repository = ref.read(nutritionRepositoryProvider);
      final updatedItem = state.value?.firstWhere((item) => item.id == itemId);
      if (updatedItem != null) {
        await repository.updateShoppingItem(updatedItem);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> updateItemQuantity(String itemId, String quantity) async {
    try {
      state = state.whenData((items) {
        return items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(quantity: quantity);
          }
          return item;
        }).toList();
      });
      
      // Persist changes
      final repository = ref.read(nutritionRepositoryProvider);
      final updatedItem = state.value?.firstWhere((item) => item.id == itemId);
      if (updatedItem != null) {
        await repository.updateShoppingItem(updatedItem);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> clearAll() async {
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.clearShoppingList();
      
      // Update state
      state = const AsyncValue.data([]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Add items from a meal plan to shopping list
  Future<void> addItemsFromMealPlan(MealPlan mealPlan) async {
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      
      // Convert ingredients to shopping list items
      final items = mealPlan.ingredients.map((ingredient) {
        // Simple parsing of ingredient string (improved parsing can be added)
        final parts = ingredient.split(' ');
        String quantity = '1';
        String name = ingredient;
        
        if (parts.length > 1 && double.tryParse(parts[0]) != null) {
          quantity = parts[0];
          if (parts.length > 2) {
            String unit = parts[1];
            name = parts.sublist(2).join(' ');
            quantity = "$quantity $unit";
          } else {
            name = parts.sublist(1).join(' ');
          }
        }
        
        return ShoppingItem(
          id: const Uuid().v4(),
          name: name,
          category: _determineCategory(name),
          quantity: quantity,
          isChecked: false,
          addedAt: DateTime.now(),
        );
      }).toList();
      
      // Add all items to the shopping list
      for (final item in items) {
        await repository.addToShoppingList(item);
      }
      
      // Refresh the list
      final updatedList = await repository.getShoppingList();
      state = AsyncValue.data(updatedList);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  // Helper method to determine category based on ingredient name
  String _determineCategory(String ingredient) {
    final lowerIngredient = ingredient.toLowerCase();
    
    // Simple categorization logic
    if (lowerIngredient.contains('milk') || 
        lowerIngredient.contains('cheese') || 
        lowerIngredient.contains('yogurt')) {
      return 'Dairy';
    } else if (lowerIngredient.contains('meat') || 
               lowerIngredient.contains('chicken') || 
               lowerIngredient.contains('beef')) {
      return 'Meat';
    } else if (lowerIngredient.contains('apple') || 
               lowerIngredient.contains('banana') || 
               lowerIngredient.contains('orange') ||
               lowerIngredient.contains('fruit')) {
      return 'Fruits';
    } else if (lowerIngredient.contains('tomato') || 
               lowerIngredient.contains('onion') || 
               lowerIngredient.contains('pepper') ||
               lowerIngredient.contains('vegetable')) {
      return 'Vegetables';
    } else if (lowerIngredient.contains('flour') || 
               lowerIngredient.contains('sugar') || 
               lowerIngredient.contains('salt')) {
      return 'Staples';
    }
    
    return 'Other';
  }

  Future<void> updateItem(ShoppingItem item) async {
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.updateShoppingItem(item);
      
      // Update current state
      state = state.whenData((items) {
        return items.map((existingItem) {
          return existingItem.id == item.id ? item : existingItem;
        }).toList();
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.removeFromShoppingList(itemId);
      
      // Remove from current state
      state = state.whenData((items) {
        return items.where((item) => item.id != itemId).toList();
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearList() async {
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.clearShoppingList();
      
      // Clear current state
      state = const AsyncValue.data([]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addMealToShoppingList(MealPlan meal) async {
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      final items = await repository.generateShoppingListFromMeal(meal);
      
      for (final item in items) {
        await repository.addToShoppingList(item);
      }
      
      // Refresh the list
      final updatedList = await repository.getShoppingList();
      state = AsyncValue.data(updatedList);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Nutrition tokens provider
final nutritionTokensProvider = AsyncNotifierProvider<NutritionTokensNotifier, List<NutritionToken>>(
  () => NutritionTokensNotifier(),
);

class NutritionTokensNotifier extends AsyncNotifier<List<NutritionToken>> {
  @override
  Future<List<NutritionToken>> build() async {
    final repository = ref.watch(nutritionRepositoryProvider);
    return await repository.getNutritionTokens();
  }

  Future<void> addToken(NutritionToken token) async {
    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.addNutritionToken(token);
      
      // Add to current state
      state = state.whenData((tokens) => [...tokens, token]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Total tokens provider
final totalTokensProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(nutritionRepositoryProvider);
  return await repository.getTotalNutritionTokens();
});

// Search provider
final mealSearchProvider = Provider.family<AsyncValue<List<MealPlan>>, String>((ref, query) {
  if (query.isEmpty) {
    return const AsyncValue.data([]);
  }
  
  final mealsAsync = ref.watch(mealPlansProvider);
  return mealsAsync.whenData((meals) {
    final lowercaseQuery = query.toLowerCase();
    return meals.where((meal) {
      return meal.recipeName.toLowerCase().contains(lowercaseQuery) ||
             meal.ingredients.any((ingredient) => 
                 ingredient.toLowerCase().contains(lowercaseQuery)) ||
             meal.culturalContext.toLowerCase().contains(lowercaseQuery);
    }).toList();
  });
});

// Current trimester provider (can be connected to user profile)
final currentTrimesterProvider = StateProvider<int>((ref) => 1);

// Selected meal type filter provider
final selectedMealTypeProvider = StateProvider<String?>((ref) => null);

// Nutritional requirements provider
final nutritionalRequirementsProvider = Provider.family<List<NutritionalRequirement>, int>((ref, trimester) {
  return PregnancyNutrition.getRequirementsForTrimester(trimester);
});

// Essential nutritional requirements provider
final essentialNutritionalRequirementsProvider = Provider.family<List<NutritionalRequirement>, int>((ref, trimester) {
  return PregnancyNutrition.getEssentialRequirements(trimester);
});
