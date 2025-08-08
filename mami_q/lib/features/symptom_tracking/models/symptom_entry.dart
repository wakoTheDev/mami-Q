class SymptomEntry {
  final String id;
  final String userId;
  final DateTime date;
  final Map<String, dynamic> symptoms;
  final int pregnancyWeek;
  final String mood;
  final List<String> concerns;
  final double energyLevel;
  final double sleepQuality;
  final List<String>? images;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  // These fields should also be final and required in constructor
  final int severity;
  final String title;
  final String description;
  final String category;

  SymptomEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.symptoms,
    required this.pregnancyWeek,
    required this.mood,
    required this.concerns,
    required this.energyLevel,
    required this.sleepQuality,
    required this.category,
    required this.title,
    required this.severity,
    required this.description,
    this.images,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  SymptomEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    Map<String, dynamic>? symptoms,
    int? pregnancyWeek,
    String? mood,
    List<String>? concerns,
    double? energyLevel,
    double? sleepQuality,
    List<String>? images,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? category,
    String? title,
    int? severity,
    String? description,
  }) {
    return SymptomEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      symptoms: symptoms ?? this.symptoms,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      mood: mood ?? this.mood,
      concerns: concerns ?? this.concerns,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      images: images ?? this.images,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      category: category ?? this.category,
      title: title ?? this.title,
      severity: severity ?? this.severity,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'symptoms': symptoms,
      'pregnancyWeek': pregnancyWeek,
      'mood': mood,
      'concerns': concerns,
      'energyLevel': energyLevel,
      'sleepQuality': sleepQuality,
      'images': images,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'category': category,
      'title': title,
      'severity': severity,
      'description': description,
    };
  }

  factory SymptomEntry.fromJson(Map<String, dynamic> json) {
    return SymptomEntry(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      symptoms: Map<String, dynamic>.from(json['symptoms']),
      pregnancyWeek: json['pregnancyWeek'],
      mood: json['mood'],
      concerns: List<String>.from(json['concerns']),
      energyLevel: json['energyLevel'].toDouble(),
      sleepQuality: json['sleepQuality'].toDouble(),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: json['isSynced'] ?? false,
      category: json['category'],
      title: json['title'],
      severity: json['severity'],
      description: json['description'],
    );
  }

  @override
  String toString() {
    return 'SymptomEntry(id: $id, userId: $userId, date: $date, pregnancyWeek: $pregnancyWeek, mood: $mood, category: $category, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SymptomEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum for symptom categories
enum SymptomCategory {
  physical,
  emotional,
  digestive,
  sleep,
  energy,
  pain,
  movement,
  other,
}

// Predefined symptoms with their categories
class SymptomDefinition {
  final String name;
  final String description;
  final SymptomCategory category;
  final bool requiresSeverity;
  final bool requiresFrequency;
  final List<String> options;

  const SymptomDefinition({
    required this.name,
    required this.description,
    required this.category,
    this.requiresSeverity = true,
    this.requiresFrequency = false,
    this.options = const [],
  });
}

class PredefinedSymptoms {
  static const List<SymptomDefinition> symptoms = [
    // Physical Symptoms
    SymptomDefinition(
      name: 'Nausea',
      description: 'Feeling of sickness or queasiness',
      category: SymptomCategory.physical,
      requiresSeverity: true,
      requiresFrequency: true,
    ),
    SymptomDefinition(
      name: 'Vomiting',
      description: 'Throwing up or retching',
      category: SymptomCategory.digestive,
      requiresFrequency: true,
    ),
    SymptomDefinition(
      name: 'Fatigue',
      description: 'Feeling tired or exhausted',
      category: SymptomCategory.energy,
      requiresSeverity: true,
    ),
    SymptomDefinition(
      name: 'Breast Tenderness',
      description: 'Soreness or sensitivity in breasts',
      category: SymptomCategory.physical,
      requiresSeverity: true,
    ),
    SymptomDefinition(
      name: 'Headache',
      description: 'Pain in the head or neck area',
      category: SymptomCategory.pain,
      requiresSeverity: true,
      requiresFrequency: true,
    ),
    SymptomDefinition(
      name: 'Back Pain',
      description: 'Pain in the lower or upper back',
      category: SymptomCategory.pain,
      requiresSeverity: true,
    ),
    SymptomDefinition(
      name: 'Constipation',
      description: 'Difficulty with bowel movements',
      category: SymptomCategory.digestive,
      requiresSeverity: true,
    ),
    SymptomDefinition(
      name: 'Heartburn',
      description: 'Burning sensation in chest or throat',
      category: SymptomCategory.digestive,
      requiresSeverity: true,
      requiresFrequency: true,
    ),
    SymptomDefinition(
      name: 'Swelling',
      description: 'Puffiness in hands, feet, or face',
      category: SymptomCategory.physical,
      requiresSeverity: true,
      options: ['Hands', 'Feet', 'Face', 'Legs', 'Ankles'],
    ),
    SymptomDefinition(
      name: 'Contractions',
      description: 'Tightening or cramping in abdomen',
      category: SymptomCategory.physical,
      requiresFrequency: true,
    ),
    
    // Emotional Symptoms
    SymptomDefinition(
      name: 'Mood Swings',
      description: 'Rapid changes in emotional state',
      category: SymptomCategory.emotional,
      requiresSeverity: true,
      requiresFrequency: true,
    ),
    SymptomDefinition(
      name: 'Anxiety',
      description: 'Feelings of worry or nervousness',
      category: SymptomCategory.emotional,
      requiresSeverity: true,
    ),
    SymptomDefinition(
      name: 'Depression',
      description: 'Persistent sadness or low mood',
      category: SymptomCategory.emotional,
      requiresSeverity: true,
    ),
    SymptomDefinition(
      name: 'Irritability',
      description: 'Feeling easily annoyed or frustrated',
      category: SymptomCategory.emotional,
      requiresSeverity: true,
    ),
    
    // Sleep Related
    SymptomDefinition(
      name: 'Insomnia',
      description: 'Difficulty falling or staying asleep',
      category: SymptomCategory.sleep,
      requiresSeverity: true,
      requiresFrequency: true,
    ),
    SymptomDefinition(
      name: 'Sleep Disturbance',
      description: 'Frequent waking during night',
      category: SymptomCategory.sleep,
      requiresFrequency: true,
    ),
    
    // Movement/Mobility
    SymptomDefinition(
      name: 'Baby Movement',
      description: 'Feeling baby kicks or movements',
      category: SymptomCategory.movement,
      requiresFrequency: true,
      options: ['Strong', 'Gentle', 'Frequent', 'Infrequent'],
    ),
    SymptomDefinition(
      name: 'Difficulty Walking',
      description: 'Trouble with mobility or balance',
      category: SymptomCategory.movement,
      requiresSeverity: true,
    ),
  ];

  static List<SymptomDefinition> getSymptomsByCategory(SymptomCategory category) {
    return symptoms.where((symptom) => symptom.category == category).toList();
  }

  static SymptomDefinition? getSymptomByName(String name) {
    try {
      return symptoms.firstWhere((symptom) => symptom.name == name);
    } catch (e) {
      return null;
    }
  }
}