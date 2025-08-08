class MealPlan {
  final String id;
  final int trimester;
  final String mealType;
  final String recipeName;
  final List<String> ingredients;
  final Map<String, String> nutritionalInfo;
  final String cookingInstructions;
  final List<String> images;
  final String culturalContext;
  final bool isLocal;
  final int preparationTime;
  final String difficulty;
  final List<String> allergens;
  final double rating;
  final int servings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  
  // Added fields needed for the UI
  final String name;
  final String description;
  final List<Meal> meals;
  final NutritionSummary nutritionSummary;
  final int? weekDay;

  MealPlan({
    required this.id,
    required this.trimester,
    required this.mealType,
    required this.recipeName,
    required this.ingredients,
    required this.nutritionalInfo,
    required this.cookingInstructions,
    required this.images,
    required this.culturalContext,
    this.isLocal = true,
    required this.preparationTime,
    required this.difficulty,
    required this.allergens,
    this.rating = 0.0,
    required this.servings,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.name = '',
    this.description = '',
    this.meals = const [],
    this.nutritionSummary = const NutritionSummary(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0),
    this.weekDay,
  });

  MealPlan copyWith({
    String? id,
    int? trimester,
    String? mealType,
    String? recipeName,
    List<String>? ingredients,
    Map<String, String>? nutritionalInfo,
    String? cookingInstructions,
    List<String>? images,
    String? culturalContext,
    bool? isLocal,
    int? preparationTime,
    String? difficulty,
    List<String>? allergens,
    double? rating,
    int? servings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    String? name,
    String? description,
    List<Meal>? meals,
    NutritionSummary? nutritionSummary,
    int? weekDay,
  }) {
    return MealPlan(
      id: id ?? this.id,
      trimester: trimester ?? this.trimester,
      mealType: mealType ?? this.mealType,
      recipeName: recipeName ?? this.recipeName,
      ingredients: ingredients ?? this.ingredients,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      cookingInstructions: cookingInstructions ?? this.cookingInstructions,
      images: images ?? this.images,
      culturalContext: culturalContext ?? this.culturalContext,
      isLocal: isLocal ?? this.isLocal,
      preparationTime: preparationTime ?? this.preparationTime,
      difficulty: difficulty ?? this.difficulty,
      allergens: allergens ?? this.allergens,
      rating: rating ?? this.rating,
      servings: servings ?? this.servings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      name: name ?? this.name,
      description: description ?? this.description,
      meals: meals ?? this.meals,
      nutritionSummary: nutritionSummary ?? this.nutritionSummary,
      weekDay: weekDay ?? this.weekDay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trimester': trimester,
      'mealType': mealType,
      'recipeName': recipeName,
      'ingredients': ingredients,
      'nutritionalInfo': nutritionalInfo,
      'cookingInstructions': cookingInstructions,
      'images': images,
      'culturalContext': culturalContext,
      'isLocal': isLocal,
      'preparationTime': preparationTime,
      'difficulty': difficulty,
      'allergens': allergens,
      'rating': rating,
      'servings': servings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'name': name,
      'description': description,
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'nutritionSummary': nutritionSummary.toJson(),
      'weekDay': weekDay,
    };
  }

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      trimester: json['trimester'],
      mealType: json['mealType'],
      recipeName: json['recipeName'],
      ingredients: List<String>.from(json['ingredients']),
      nutritionalInfo: Map<String, String>.from(json['nutritionalInfo']),
      cookingInstructions: json['cookingInstructions'],
      images: List<String>.from(json['images']),
      culturalContext: json['culturalContext'],
      isLocal: json['isLocal'] ?? true,
      preparationTime: json['preparationTime'],
      difficulty: json['difficulty'],
      allergens: List<String>.from(json['allergens']),
      rating: json['rating']?.toDouble() ?? 0.0,
      servings: json['servings'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isFavorite: json['isFavorite'] ?? false,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      meals: (json['meals'] as List<dynamic>? ?? [])
          .map((mealJson) => Meal.fromJson(mealJson))
          .toList(),
      nutritionSummary: NutritionSummary.fromJson(json['nutritionSummary']),
      weekDay: json['weekDay'],
    );
  }

  @override
  String toString() {
    return 'MealPlan(id: $id, recipeName: $recipeName, mealType: $mealType, trimester: $trimester)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPlan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class NutritionToken {
  final String userId;
  final int tokenCount;
  final DateTime earnedDate;
  final String activity;
  final String mealId;
  final TokenType type;
  final int points;

  NutritionToken({
    required this.userId,
    required this.tokenCount,
    required this.earnedDate,
    required this.activity,
    required this.mealId,
    required this.type,
    required this.points,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tokenCount': tokenCount,
      'earnedDate': earnedDate.toIso8601String(),
      'activity': activity,
      'mealId': mealId,
      'type': type.name,
      'points': points,
    };
  }

  factory NutritionToken.fromJson(Map<String, dynamic> json) {
    return NutritionToken(
      userId: json['userId'],
      tokenCount: json['tokenCount'],
      earnedDate: DateTime.parse(json['earnedDate']),
      activity: json['activity'],
      mealId: json['mealId'],
      type: TokenType.values.firstWhere((e) => e.name == json['type']),
      points: json['points'],
    );
  }
}

enum TokenType {
  mealPreparation,
  recipeSharing,
  nutritionGoal,
  healthyChoice,
  cookingChallenge,
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  drink,
}

enum Difficulty {
  easy,
  medium,
  hard,
}

class NutritionalRequirement {
  final String nutrient;
  final double dailyValue;
  final String unit;
  final int trimester;
  final bool isEssential;

  const NutritionalRequirement({
    required this.nutrient,
    required this.dailyValue,
    required this.unit,
    required this.trimester,
    this.isEssential = false,
  });
}

class PregnancyNutrition {
  static const List<NutritionalRequirement> requirements = [
    // First Trimester (1-12 weeks)
    NutritionalRequirement(
      nutrient: 'Folic Acid',
      dailyValue: 600,
      unit: 'mcg',
      trimester: 1,
      isEssential: true,
    ),
    NutritionalRequirement(
      nutrient: 'Iron',
      dailyValue: 27,
      unit: 'mg',
      trimester: 1,
      isEssential: true,
    ),
    NutritionalRequirement(
      nutrient: 'Calcium',
      dailyValue: 1000,
      unit: 'mg',
      trimester: 1,
      isEssential: true,
    ),
    NutritionalRequirement(
      nutrient: 'Protein',
      dailyValue: 71,
      unit: 'g',
      trimester: 1,
      isEssential: true,
    ),
    NutritionalRequirement(
      nutrient: 'Vitamin D',
      dailyValue: 600,
      unit: 'IU',
      trimester: 1,
      isEssential: true,
    ),
    NutritionalRequirement(
      nutrient: 'DHA',
      dailyValue: 200,
      unit: 'mg',
      trimester: 1,
      isEssential: true,
    ),

    // Second Trimester (13-27 weeks)
    NutritionalRequirement(
      nutrient: 'Folic Acid',
      dailyValue: 600,
      unit: 'mcg',
      trimester: 2,
      isEssential: true,
    ),
    NutritionalRequirement(
      nutrient: 'Iron',
      dailyValue: 27,
      unit: 'mg',
      trimester: 2,
      isEssential: true,
    ),
    NutritionalRequirement(
      nutrient: 'Calcium',
      dailyValue: 1000,
      unit: 'mg',
      trimester: 2,
      isEssential: true,
    ),
    NutritionalRequirement(
      nutrient: 'Protein',
      dailyValue: 71,
      unit: 'g',
      trimester: 2,
      isEssential: true,
    ),
    NutritionalRequirement(
      nutrient: 'Vitamin C',
      dailyValue: 85,
      unit: 'mg',
      trimester: 2,
    ),

    // Third Trimester (28-40 weeks)
    NutritionalRequirement(
      nutrient: 'Folic Acid',
      dailyValue: 600,
      unit: 'mcg',
      trimester: 3,
      isEssential: true,
    ),
    NutritionalRequirement(
      nutrient: 'Iron',
      dailyValue: 27,
      unit: 'mg',
      trimester: 3,
      isEssential: true,
    ),
    NutritionalRequirement(
      nutrient: 'Calcium',
      dailyValue: 1200,
      unit: 'mg',
      trimester: 3,
      isEssential: true,
    ),
    NutritionalRequirement(
      nutrient: 'Protein',
      dailyValue: 75,
      unit: 'g',
      trimester: 3,
      isEssential: true,
    ),
    NutritionalRequirement(
      nutrient: 'Choline',
      dailyValue: 450,
      unit: 'mg',
      trimester: 3,
      isEssential: true,
    ),
  ];

  static List<NutritionalRequirement> getRequirementsForTrimester(int trimester) {
    return requirements.where((req) => req.trimester == trimester).toList();
  }

  static List<NutritionalRequirement> getEssentialRequirements(int trimester) {
    return requirements
        .where((req) => req.trimester == trimester && req.isEssential)
        .toList();
  }
}

class LocalAfricanCuisine {
  static const Map<String, List<String>> cuisineByRegion = {
    'West Africa': [
      'Jollof Rice with Vegetables',
      'Groundnut Soup with Lean Meat',
      'Plantain and Beans (Red Red)',
      'Okra Stew with Fish',
      'Millet Porridge with Dates',
      'Vegetable Soup with Fufu',
      'Steamed Fish with Vegetables',
      'Bean Cake (Akara) with Vegetables',
    ],
    'East Africa': [
      'Ugali with Sukuma Wiki',
      'Lentil Curry with Rice',
      'Pilau Rice with Vegetables',
      'Samosa with Vegetable Filling',
      'Chapati with Bean Stew',
      'Githeri (Corn and Beans)',
      'Nyama Choma with Salad',
      'Mandazi with Fruit',
    ],
    'Southern Africa': [
      'Pap with Morogo (Spinach)',
      'Samp and Beans',
      'Bobotie with Vegetables',
      'Potjiekos with Lean Meat',
      'Braai Fish with Salad',
      'Chakalaka with Pap',
      'Sosaties with Rice',
      'Milk Tart (Modified)',
    ],
    'Central Africa': [
      'Cassava with Fish Stew',
      'Plantain Fufu with Vegetable Soup',
      'Palm Nut Soup with Rice',
      'Grilled Tilapia with Vegetables',
      'Sweet Potato with Beans',
      'Chicken Stew with Yams',
      'Fish Pepper Soup',
      'Coconut Rice with Vegetables',
    ],
  };

  static List<String> getAllDishes() {
    return cuisineByRegion.values.expand((dishes) => dishes).toList();
  }

  static List<String> getDishesByRegion(String region) {
    return cuisineByRegion[region] ?? [];
  }
}

class ShoppingListItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double estimatedPrice;
  final String currency;
  final bool isPurchased;
  final bool isLocal;
  final String? notes;

  ShoppingListItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.estimatedPrice,
    this.currency = 'USD',
    this.isPurchased = false,
    this.isLocal = true,
    this.notes,
  });

  ShoppingListItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    double? estimatedPrice,
    String? currency,
    bool? isPurchased,
    bool? isLocal,
    String? notes,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      currency: currency ?? this.currency,
      isPurchased: isPurchased ?? this.isPurchased,
      isLocal: isLocal ?? this.isLocal,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'estimatedPrice': estimatedPrice,
      'currency': currency,
      'isPurchased': isPurchased,
      'isLocal': isLocal,
      'notes': notes,
    };
  }

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      estimatedPrice: json['estimatedPrice'].toDouble(),
      currency: json['currency'] ?? 'USD',
      isPurchased: json['isPurchased'] ?? false,
      isLocal: json['isLocal'] ?? true,
      notes: json['notes'],
    );
  }
}

class NutritionSummary {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  
  const NutritionSummary({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
    };
  }
  
  factory NutritionSummary.fromJson(Map<String, dynamic> json) {
    return NutritionSummary(
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fat: json['fat'] ?? 0,
      fiber: json['fiber'] ?? 0,
    );
  }
}

class Meal {
  final String id;
  final String name;
  final String timeOfDay;
  final List<String> foods;
  final Recipe? recipe;
  
  const Meal({
    required this.id,
    required this.name,
    required this.timeOfDay,
    required this.foods,
    this.recipe,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'timeOfDay': timeOfDay,
      'foods': foods,
      'recipe': recipe?.toJson(),
    };
  }
  
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      timeOfDay: json['timeOfDay'],
      foods: List<String>.from(json['foods'] ?? []),
      recipe: json['recipe'] != null ? Recipe.fromJson(json['recipe']) : null,
    );
  }
}

class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;
  final int prepTime;
  final int cookTime;
  final String difficulty;
  final int servings;
  final NutritionSummary nutritionSummary;
  
  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.prepTime,
    required this.cookTime,
    required this.difficulty,
    required this.servings,
    required this.nutritionSummary,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'imageUrl': imageUrl,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'difficulty': difficulty,
      'servings': servings,
      'nutritionSummary': nutritionSummary.toJson(),
    };
  }
  
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      prepTime: json['prepTime'] ?? 0,
      cookTime: json['cookTime'] ?? 0,
      difficulty: json['difficulty'] ?? 'Medium',
      servings: json['servings'] ?? 1,
      nutritionSummary: json['nutritionSummary'] != null 
        ? NutritionSummary.fromJson(json['nutritionSummary']) 
        : const NutritionSummary(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0),
    );
  }
}
