class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String? imageUrl;
  final int prepTime;
  final int cookTime;
  final int servings;
  final NutritionInfo nutrition;
  final List<String> tags;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    this.imageUrl,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.nutrition,
    required this.tags,
  });
  
  // Convert to JSON
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
      'servings': servings,
      'nutrition': {
        'calories': nutrition.calories,
        'protein': nutrition.protein,
        'carbs': nutrition.carbs,
        'fat': nutrition.fat,
        'fiber': nutrition.fiber,
      },
      'tags': tags,
    };
  }
  
  // Create from JSON
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      steps: List<String>.from(json['steps']),
      imageUrl: json['imageUrl'],
      prepTime: json['prepTime'],
      cookTime: json['cookTime'],
      servings: json['servings'],
      nutrition: NutritionInfo(
        calories: json['nutrition']['calories'],
        protein: json['nutrition']['protein'],
        carbs: json['nutrition']['carbs'],
        fat: json['nutrition']['fat'],
        fiber: json['nutrition']['fiber'],
      ),
      tags: List<String>.from(json['tags']),
    );
  }
}

class NutritionInfo {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });
}
