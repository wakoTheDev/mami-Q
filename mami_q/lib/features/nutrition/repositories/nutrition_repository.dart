import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_plan.dart' hide Recipe;
import '../models/recipe.dart';
import '../models/shopping_item.dart';

class NutritionRepository {
  static const String _mealPlansKey = 'meal_plans';
  static const String _favoriteMealsKey = 'favorite_meals';
  static const String _shoppingListKey = 'shopping_list';
  static const String _nutritionTokensKey = 'nutrition_tokens';
  static const String _recipesKey = 'recipes';

  // Get all meal plans
  Future<List<MealPlan>> getMealPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final mealPlansJson = prefs.getStringList(_mealPlansKey) ?? [];
    
    if (mealPlansJson.isEmpty) {
      // Return sample data if no meals exist
      return _getSampleMealPlans();
    }
    
    return mealPlansJson
        .map((jsonString) => MealPlan.fromJson(json.decode(jsonString)))
        .toList();
  }

  // Get meal plans by trimester
  Future<List<MealPlan>> getMealPlansByTrimester(int trimester) async {
    final allMeals = await getMealPlans();
    return allMeals.where((meal) => meal.trimester == trimester).toList();
  }

  // Get meal plans by meal type
  Future<List<MealPlan>> getMealPlansByType(String mealType) async {
    final allMeals = await getMealPlans();
    return allMeals.where((meal) => meal.mealType == mealType).toList();
  }

  // Save meal plan
  Future<void> saveMealPlan(MealPlan mealPlan) async {
    final prefs = await SharedPreferences.getInstance();
    final mealPlansJson = prefs.getStringList(_mealPlansKey) ?? [];
    
    // Remove existing meal plan with same ID if it exists
    mealPlansJson.removeWhere((jsonString) {
      final meal = MealPlan.fromJson(json.decode(jsonString));
      return meal.id == mealPlan.id;
    });
    
    // Add updated meal plan
    mealPlansJson.add(json.encode(mealPlan.toJson()));
    await prefs.setStringList(_mealPlansKey, mealPlansJson);
  }

  // Delete meal plan
  Future<void> deleteMealPlan(String mealPlanId) async {
    final prefs = await SharedPreferences.getInstance();
    final mealPlansJson = prefs.getStringList(_mealPlansKey) ?? [];
    
    mealPlansJson.removeWhere((jsonString) {
      final meal = MealPlan.fromJson(json.decode(jsonString));
      return meal.id == mealPlanId;
    });
    
    await prefs.setStringList(_mealPlansKey, mealPlansJson);
  }

  // Toggle favorite meal
  Future<void> toggleFavoriteMeal(String mealPlanId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteMeals = prefs.getStringList(_favoriteMealsKey) ?? [];
    
    if (favoriteMeals.contains(mealPlanId)) {
      favoriteMeals.remove(mealPlanId);
    } else {
      favoriteMeals.add(mealPlanId);
    }
    
    await prefs.setStringList(_favoriteMealsKey, favoriteMeals);
  }

  // Get favorite meals
  Future<List<MealPlan>> getFavoriteMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteMeals = prefs.getStringList(_favoriteMealsKey) ?? [];
    final allMeals = await getMealPlans();
    
    return allMeals.where((meal) => favoriteMeals.contains(meal.id)).toList();
  }

  // Check if meal is favorite
  Future<bool> isMealFavorite(String mealPlanId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteMeals = prefs.getStringList(_favoriteMealsKey) ?? [];
    return favoriteMeals.contains(mealPlanId);
  }

  // Shopping list operations
  Future<List<ShoppingItem>> getShoppingList() async {
    final prefs = await SharedPreferences.getInstance();
    final shoppingListJson = prefs.getStringList(_shoppingListKey) ?? [];
    
    if (shoppingListJson.isEmpty) {
      // Return sample data for testing
      return _getSampleShoppingItems();
    }
    
    return shoppingListJson
        .map((jsonString) => ShoppingItem.fromJson(json.decode(jsonString)))
        .toList();
  }

  Future<void> addToShoppingList(ShoppingItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final shoppingListJson = prefs.getStringList(_shoppingListKey) ?? [];
    
    shoppingListJson.add(json.encode(item.toJson()));
    await prefs.setStringList(_shoppingListKey, shoppingListJson);
  }

  Future<void> updateShoppingItem(ShoppingItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final shoppingListJson = prefs.getStringList(_shoppingListKey) ?? [];
    
    // Remove existing item
    shoppingListJson.removeWhere((jsonString) {
      final existingItem = ShoppingItem.fromJson(json.decode(jsonString));
      return existingItem.id == item.id;
    });
    
    // Add updated item
    shoppingListJson.add(json.encode(item.toJson()));
    await prefs.setStringList(_shoppingListKey, shoppingListJson);
  }

  Future<void> removeFromShoppingList(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final shoppingListJson = prefs.getStringList(_shoppingListKey) ?? [];
    
    shoppingListJson.removeWhere((jsonString) {
      final item = ShoppingItem.fromJson(json.decode(jsonString));
      return item.id == itemId;
    });
    
    await prefs.setStringList(_shoppingListKey, shoppingListJson);
  }

  Future<void> clearShoppingList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shoppingListKey);
  }

  // Nutrition tokens operations
  Future<List<NutritionToken>> getNutritionTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final tokensJson = prefs.getStringList(_nutritionTokensKey) ?? [];
    
    return tokensJson
        .map((jsonString) => NutritionToken.fromJson(json.decode(jsonString)))
        .toList();
  }

  Future<void> addNutritionToken(NutritionToken token) async {
    final prefs = await SharedPreferences.getInstance();
    final tokensJson = prefs.getStringList(_nutritionTokensKey) ?? [];
    
    tokensJson.add(json.encode(token.toJson()));
    await prefs.setStringList(_nutritionTokensKey, tokensJson);
  }

  Future<int> getTotalNutritionTokens() async {
    final tokens = await getNutritionTokens();
    return tokens.fold<int>(0, (total, token) => total + token.tokenCount);
  }

  // Search meals
  Future<List<MealPlan>> searchMeals(String query) async {
    final allMeals = await getMealPlans();
    final lowercaseQuery = query.toLowerCase();
    
    return allMeals.where((meal) {
      return meal.recipeName.toLowerCase().contains(lowercaseQuery) ||
             meal.ingredients.any((ingredient) => 
                 ingredient.toLowerCase().contains(lowercaseQuery)) ||
             meal.culturalContext.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Generate shopping list from meal plan
  Future<List<ShoppingItem>> generateShoppingListFromMeal(MealPlan meal) async {
    return meal.ingredients.asMap().entries.map((entry) {
      return ShoppingItem(
        id: '${meal.id}_ingredient_${entry.key}',
        name: entry.value,
        category: _getCategoryForIngredient(entry.value),
        quantity: '1 piece',
        isChecked: false,
        addedAt: DateTime.now(),
      );
    }).toList();
  }

  String _getCategoryForIngredient(String ingredient) {
    final lowercaseIngredient = ingredient.toLowerCase();
    
    if (lowercaseIngredient.contains('tomato') || 
        lowercaseIngredient.contains('onion') ||
        lowercaseIngredient.contains('pepper') ||
        lowercaseIngredient.contains('carrot') ||
        lowercaseIngredient.contains('spinach')) {
      return 'Vegetables';
    } else if (lowercaseIngredient.contains('rice') ||
               lowercaseIngredient.contains('bread') ||
               lowercaseIngredient.contains('pasta') ||
               lowercaseIngredient.contains('flour')) {
      return 'Grains';
    } else if (lowercaseIngredient.contains('chicken') ||
               lowercaseIngredient.contains('fish') ||
               lowercaseIngredient.contains('beef') ||
               lowercaseIngredient.contains('egg')) {
      return 'Protein';
    } else if (lowercaseIngredient.contains('milk') ||
               lowercaseIngredient.contains('cheese') ||
               lowercaseIngredient.contains('yogurt')) {
      return 'Dairy';
    } else {
      return 'Other';
    }
  }

  double _getEstimatedPrice(String ingredient) {
    // Simple price estimation based on ingredient type
    final lowercaseIngredient = ingredient.toLowerCase();
    
    if (lowercaseIngredient.contains('chicken') || 
        lowercaseIngredient.contains('beef')) {
      return 5.0;
    } else if (lowercaseIngredient.contains('fish')) {
      return 4.0;
    } else if (lowercaseIngredient.contains('rice') ||
               lowercaseIngredient.contains('bread')) {
      return 2.0;
    } else {
      return 1.0;
    }
  }

  // Sample data for initial population
  List<MealPlan> _getSampleMealPlans() {
    return [
      MealPlan(
        id: 'meal_1',
        trimester: 1,
        mealType: 'breakfast',
        recipeName: 'Jollof Rice with Vegetables',
        ingredients: [
          'Rice (2 cups)',
          'Tomatoes (3 large)',
          'Onions (2 medium)',
          'Bell peppers (2)',
          'Carrots (1 cup diced)',
          'Green peas (1/2 cup)',
          'Vegetable oil (3 tbsp)',
          'Chicken stock (2 cups)',
          'Bay leaves (2)',
          'Thyme (1 tsp)',
          'Curry powder (1 tsp)',
          'Salt and pepper to taste'
        ],
        nutritionalInfo: {
          'Calories': '320',
          'Protein': '8g',
          'Carbohydrates': '65g',
          'Fat': '5g',
          'Fiber': '4g',
          'Iron': '2mg',
          'Vitamin C': '45mg'
        },
        cookingInstructions: '''
1. Wash and parboil rice until 70% cooked, then drain.
2. Blend tomatoes, onions, and bell peppers into a smooth paste.
3. Heat oil in a large pot and fry the blended mixture for 10-15 minutes.
4. Add chicken stock, bay leaves, thyme, curry powder, salt, and pepper.
5. Bring to boil, then add the parboiled rice.
6. Add diced carrots and green peas.
7. Cover and cook on low heat for 15-20 minutes until rice is tender.
8. Stir occasionally and add water if needed.
9. Serve hot with a side of salad.
        ''',
        images: ['assets/images/jollof_rice.jpg'],
        culturalContext: 'West African',
        isLocal: true,
        preparationTime: 45,
        difficulty: 'medium',
        allergens: [],
        rating: 4.5,
        servings: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        isFavorite: false,
      ),
      MealPlan(
        id: 'meal_2',
        trimester: 1,
        mealType: 'lunch',
        recipeName: 'Groundnut Soup with Lean Chicken',
        ingredients: [
          'Groundnuts (1 cup)',
          'Lean chicken (500g)',
          'Spinach (2 cups chopped)',
          'Tomatoes (2 medium)',
          'Onions (1 large)',
          'Ginger (1 tbsp minced)',
          'Garlic (2 cloves)',
          'Palm oil (2 tbsp)',
          'Stock cubes (2)',
          'Salt to taste',
          'Hot pepper (optional)'
        ],
        nutritionalInfo: {
          'Calories': '385',
          'Protein': '28g',
          'Carbohydrates': '12g',
          'Fat': '25g',
          'Fiber': '5g',
          'Iron': '4mg',
          'Folate': '85mcg',
          'Calcium': '120mg'
        },
        cookingInstructions: '''
1. Roast groundnuts and blend into a smooth paste with a little water.
2. Season and boil chicken until tender, reserve the stock.
3. Heat palm oil and sauté onions, garlic, and ginger.
4. Add blended tomatoes and cook for 10 minutes.
5. Add groundnut paste and chicken stock, stir well.
6. Add cooked chicken and simmer for 15 minutes.
7. Add chopped spinach in the last 5 minutes.
8. Season with salt and serve with rice or fufu.
        ''',
        images: ['assets/images/groundnut_soup.jpg'],
        culturalContext: 'West African',
        isLocal: true,
        preparationTime: 60,
        difficulty: 'medium',
        allergens: ['Nuts'],
        rating: 4.7,
        servings: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        isFavorite: true,
      ),
      MealPlan(
        id: 'meal_3',
        trimester: 2,
        mealType: 'dinner',
        recipeName: 'Ugali with Sukuma Wiki',
        ingredients: [
          'Maize flour (2 cups)',
          'Water (3 cups)',
          'Collard greens/Kale (4 cups chopped)',
          'Tomatoes (2 medium)',
          'Onions (1 large)',
          'Cooking oil (2 tbsp)',
          'Salt to taste',
          'Royco cube (1)',
          'Coriander (optional)'
        ],
        nutritionalInfo: {
          'Calories': '290',
          'Protein': '12g',
          'Carbohydrates': '55g',
          'Fat': '4g',
          'Fiber': '8g',
          'Iron': '3mg',
          'Vitamin K': '120mcg',
          'Folate': '65mcg'
        },
        cookingInstructions: '''
1. Boil water in a heavy-bottomed pot.
2. Gradually add maize flour while stirring continuously.
3. Cook for 15-20 minutes, stirring frequently until thick.
4. For sukuma wiki: heat oil and sauté onions until golden.
5. Add tomatoes and cook until soft.
6. Add chopped greens and cook for 5-7 minutes.
7. Season with salt and royco cube.
8. Serve ugali with sukuma wiki.
        ''',
        images: ['assets/images/ugali_sukuma.jpg'],
        culturalContext: 'East African',
        isLocal: true,
        preparationTime: 30,
        difficulty: 'easy',
        allergens: [],
        rating: 4.2,
        servings: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        isFavorite: false,
      ),
    ];
  }

  // Get all recipes
  Future<List<Recipe>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getStringList(_recipesKey) ?? [];
    
    if (recipesJson.isEmpty) {
      // Return sample data if no recipes exist
      return _getSampleRecipes();
    }
    
    try {
      return recipesJson
          .map((jsonString) => Recipe.fromJson(json.decode(jsonString)))
          .toList();
    } catch (e) {
      // Return sample data if there's an error parsing the stored data
      print('Error loading recipes: $e');
      return _getSampleRecipes();
    }
  }

  // Get recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    final recipes = await getRecipes();
    try {
      return recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  // Save recipe
  Future<void> saveRecipe(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getStringList(_recipesKey) ?? [];
    
    // Remove existing recipe with same ID if it exists
    recipesJson.removeWhere((jsonString) {
      try {
        final existingRecipe = Recipe.fromJson(json.decode(jsonString));
        return existingRecipe.id == recipe.id;
      } catch (e) {
        return false;
      }
    });
    
    // Add updated recipe
    recipesJson.add(json.encode(recipe.toJson()));
    
    // Save back to shared preferences
    await prefs.setStringList(_recipesKey, recipesJson);
  }

  // Delete recipe
  Future<void> deleteRecipe(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getStringList(_recipesKey) ?? [];
    
    // Remove recipe with matching ID
    recipesJson.removeWhere((jsonString) {
      try {
        final recipe = Recipe.fromJson(json.decode(jsonString));
        return recipe.id == recipeId;
      } catch (e) {
        return false;
      }
    });
    
    // Save back to shared preferences
    await prefs.setStringList(_recipesKey, recipesJson);
  }

  // Get sample recipes
  List<Recipe> _getSampleRecipes() {
    return [
      Recipe(
        id: 'recipe-1',
        name: 'Spinach and Feta Omelette',
        description: 'A nutritious breakfast rich in protein and iron, perfect for pregnant women.',
        ingredients: [
          '3 large eggs',
          '1 cup fresh spinach, chopped',
          '1/4 cup feta cheese, crumbled',
          '1 tablespoon olive oil',
          'Salt and pepper to taste',
        ],
        steps: [
          'Heat olive oil in a non-stick skillet over medium heat.',
          'In a bowl, whisk eggs with salt and pepper.',
          'Add spinach to the skillet and cook until wilted, about 1 minute.',
          'Pour egg mixture over spinach and cook until edges start to set.',
          'Sprinkle feta cheese over one half of the omelette.',
          'Fold omelette in half and cook for another minute.',
          'Serve hot with whole grain toast.',
        ],
        prepTime: 5,
        cookTime: 10,
        servings: 1,
        nutrition: NutritionInfo(
          calories: 350,
          protein: 22,
          carbs: 5,
          fat: 26,
          fiber: 2,
        ),
        tags: ['breakfast', 'high-protein', 'folate-rich', 'iron-rich'],
      ),
      Recipe(
        id: 'recipe-2',
        name: 'Berry Banana Smoothie',
        description: 'A refreshing smoothie packed with vitamins and antioxidants for pregnancy.',
        ingredients: [
          '1 ripe banana',
          '1 cup mixed berries (strawberries, blueberries)',
          '1 cup Greek yogurt',
          '1 tablespoon honey',
          '1/2 cup almond milk',
          '1 tablespoon chia seeds',
        ],
        steps: [
          'Place all ingredients in a blender.',
          'Blend until smooth and creamy.',
          'Add more almond milk if needed to adjust consistency.',
          'Pour into a glass and enjoy immediately.',
        ],
        prepTime: 5,
        cookTime: 0,
        servings: 1,
        nutrition: NutritionInfo(
          calories: 320,
          protein: 14,
          carbs: 56,
          fat: 8,
          fiber: 9,
        ),
        tags: ['breakfast', 'snack', 'calcium-rich', 'vitamin-c'],
      ),
      Recipe(
        id: 'recipe-3',
        name: 'Quinoa and Chickpea Salad',
        description: 'A protein-packed lunch with essential nutrients for pregnancy.',
        ingredients: [
          '1 cup cooked quinoa',
          '1 cup chickpeas, drained and rinsed',
          '1 cucumber, diced',
          '1 cup cherry tomatoes, halved',
          '1/4 cup red onion, finely chopped',
          '1/4 cup feta cheese, crumbled',
          '2 tablespoons olive oil',
          '1 tablespoon lemon juice',
          'Salt and pepper to taste',
        ],
        steps: [
          'In a large bowl, combine quinoa and chickpeas.',
          'Add cucumber, tomatoes, red onion, and feta cheese.',
          'In a small bowl, whisk together olive oil, lemon juice, salt, and pepper.',
          'Pour dressing over salad and toss to combine.',
          'Refrigerate for 30 minutes before serving for best flavor.',
        ],
        prepTime: 15,
        cookTime: 0,
        servings: 2,
        nutrition: NutritionInfo(
          calories: 420,
          protein: 15,
          carbs: 52,
          fat: 18,
          fiber: 12,
        ),
        tags: ['lunch', 'protein-rich', 'fiber-rich', 'iron-rich'],
      ),
    ];
  }

  List<ShoppingItem> _getSampleShoppingItems() {
    return [
      ShoppingItem(
        id: 'item-1',
        name: 'Spinach',
        quantity: '1 bunch',
        category: 'Vegetables',
        isChecked: false,
        addedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ShoppingItem(
        id: 'item-2',
        name: 'Whole wheat bread',
        quantity: '1 loaf',
        category: 'Grains',
        isChecked: false,
        addedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ShoppingItem(
        id: 'item-3',
        name: 'Greek yogurt',
        quantity: '500g',
        category: 'Dairy',
        isChecked: false,
        addedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ShoppingItem(
        id: 'item-4',
        name: 'Salmon fillet',
        quantity: '2 pieces',
        category: 'Protein',
        isChecked: false,
        addedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ShoppingItem(
        id: 'item-5',
        name: 'Avocado',
        quantity: '3',
        category: 'Fruits',
        isChecked: false,
        addedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
