class TokenSystem {
  final String userId;
  final int totalTokens;
  final int availableTokens;
  final List<TokenTransaction> transactions;
  final Map<String, int> categoryEarnings;
  final int currentStreak;
  final DateTime lastActivityDate;
  final UserTier tier;
  final DateTime createdAt;
  final DateTime updatedAt;

  TokenSystem({
    required this.userId,
    this.totalTokens = 0,
    this.availableTokens = 0,
    this.transactions = const [],
    this.categoryEarnings = const {},
    this.currentStreak = 0,
    required this.lastActivityDate,
    this.tier = UserTier.bronze,
    required this.createdAt,
    required this.updatedAt,
  });

  TokenSystem copyWith({
    String? userId,
    int? totalTokens,
    int? availableTokens,
    List<TokenTransaction>? transactions,
    Map<String, int>? categoryEarnings,
    int? currentStreak,
    DateTime? lastActivityDate,
    UserTier? tier,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TokenSystem(
      userId: userId ?? this.userId,
      totalTokens: totalTokens ?? this.totalTokens,
      availableTokens: availableTokens ?? this.availableTokens,
      transactions: transactions ?? this.transactions,
      categoryEarnings: categoryEarnings ?? this.categoryEarnings,
      currentStreak: currentStreak ?? this.currentStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      tier: tier ?? this.tier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalTokens': totalTokens,
      'availableTokens': availableTokens,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'categoryEarnings': categoryEarnings,
      'currentStreak': currentStreak,
      'lastActivityDate': lastActivityDate.toIso8601String(),
      'tier': tier.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TokenSystem.fromJson(Map<String, dynamic> json) {
    return TokenSystem(
      userId: json['userId'],
      totalTokens: json['totalTokens'] ?? 0,
      availableTokens: json['availableTokens'] ?? 0,
      transactions: (json['transactions'] as List? ?? [])
          .map((t) => TokenTransaction.fromJson(t))
          .toList(),
      categoryEarnings: Map<String, int>.from(json['categoryEarnings'] ?? {}),
      currentStreak: json['currentStreak'] ?? 0,
      lastActivityDate: DateTime.parse(json['lastActivityDate']),
      tier: UserTier.values.firstWhere(
        (tier) => tier.name == json['tier'],
        orElse: () => UserTier.bronze,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class TokenTransaction {
  final String id;
  final String userId;
  final int amount;
  final TokenTransactionType type;
  final String activity;
  final String? description;
  final DateTime timestamp;
  final String? relatedId;
  final Map<String, dynamic>? metadata;

  TokenTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.activity,
    this.description,
    required this.timestamp,
    this.relatedId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.name,
      'activity': activity,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'relatedId': relatedId,
      'metadata': metadata,
    };
  }

  factory TokenTransaction.fromJson(Map<String, dynamic> json) {
    return TokenTransaction(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount'],
      type: TokenTransactionType.values.firstWhere(
        (type) => type.name == json['type'],
      ),
      activity: json['activity'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      relatedId: json['relatedId'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }
}

enum TokenTransactionType {
  earned,
  spent,
  bonus,
  penalty,
  refund,
  expired,
}

enum UserTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

class Reward {
  final String id;
  final String name;
  final int tokenCost;
  final String category;
  final String partnerId;
  final String partnerName;
  final DateTime? expiryDate;
  final String description;
  final String? imageUrl;
  final bool isAvailable;
  final int stockQuantity;
  final List<String> terms;
  final RewardType type;
  final String? discountCode;
  final double? discountPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reward({
    required this.id,
    required this.name,
    required this.tokenCost,
    required this.category,
    required this.partnerId,
    required this.partnerName,
    this.expiryDate,
    required this.description,
    this.imageUrl,
    this.isAvailable = true,
    this.stockQuantity = -1, // -1 means unlimited
    this.terms = const [],
    required this.type,
    this.discountCode,
    this.discountPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tokenCost': tokenCost,
      'category': category,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'expiryDate': expiryDate?.toIso8601String(),
      'description': description,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'stockQuantity': stockQuantity,
      'terms': terms,
      'type': type.name,
      'discountCode': discountCode,
      'discountPercentage': discountPercentage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      name: json['name'],
      tokenCost: json['tokenCost'],
      category: json['category'],
      partnerId: json['partnerId'],
      partnerName: json['partnerName'],
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      description: json['description'],
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
      stockQuantity: json['stockQuantity'] ?? -1,
      terms: List<String>.from(json['terms'] ?? []),
      type: RewardType.values.firstWhere(
        (type) => type.name == json['type'],
      ),
      discountCode: json['discountCode'],
      discountPercentage: json['discountPercentage']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum RewardType {
  discount,
  freeItem,
  consultation,
  upgrade,
  gift,
  voucher,
}

class RewardRedemption {
  final String id;
  final String userId;
  final String rewardId;
  final String rewardName;
  final int tokensCost;
  final DateTime redeemedAt;
  final RedemptionStatus status;
  final String? redemptionCode;
  final DateTime? usedAt;
  final DateTime? expiryDate;
  final String? notes;

  RewardRedemption({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.rewardName,
    required this.tokensCost,
    required this.redeemedAt,
    this.status = RedemptionStatus.active,
    this.redemptionCode,
    this.usedAt,
    this.expiryDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'rewardId': rewardId,
      'rewardName': rewardName,
      'tokensCost': tokensCost,
      'redeemedAt': redeemedAt.toIso8601String(),
      'status': status.name,
      'redemptionCode': redemptionCode,
      'usedAt': usedAt?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory RewardRedemption.fromJson(Map<String, dynamic> json) {
    return RewardRedemption(
      id: json['id'],
      userId: json['userId'],
      rewardId: json['rewardId'],
      rewardName: json['rewardName'],
      tokensCost: json['tokensCost'],
      redeemedAt: DateTime.parse(json['redeemedAt']),
      status: RedemptionStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => RedemptionStatus.active,
      ),
      redemptionCode: json['redemptionCode'],
      usedAt: json['usedAt'] != null
          ? DateTime.parse(json['usedAt'])
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      notes: json['notes'],
    );
  }
}

enum RedemptionStatus {
  active,
  used,
  expired,
  cancelled,
}

class TokenEarningRules {
  static Map<String, int> getBaseTokens() {
    return {
      'daily_symptom_log': 5,
      'meal_preparation': 10,
      'exercise_session': 15,
      'appointment_attendance': 20,
      'community_post': 3,
      'recipe_sharing': 8,
      'health_goal_completion': 12,
      'prenatal_vitamin': 2,
      'water_intake_goal': 3,
      'sleep_tracking': 4,
      'weight_tracking': 3,
      'blood_pressure_log': 5,
      'mood_tracking': 2,
      'photo_milestone': 6,
      'educational_content_read': 1,
      'quiz_completion': 5,
      'referral_signup': 50,
      'first_time_bonus': 25,
      'weekly_challenge': 30,
      'monthly_challenge': 100,
    };
  }

  static Map<int, double> getStreakMultipliers() {
    return {
      7: 1.2,   // 20% bonus after 1 week
      14: 1.5,  // 50% bonus after 2 weeks
      30: 2.0,  // 100% bonus after 1 month
      60: 2.5,  // 150% bonus after 2 months
      90: 3.0,  // 200% bonus after 3 months
    };
  }

  static Map<UserTier, double> getTierMultipliers() {
    return {
      UserTier.bronze: 1.0,
      UserTier.silver: 1.1,
      UserTier.gold: 1.25,
      UserTier.platinum: 1.5,
      UserTier.diamond: 2.0,
    };
  }

  static Map<UserTier, int> getTierRequirements() {
    return {
      UserTier.bronze: 0,
      UserTier.silver: 500,
      UserTier.gold: 2000,
      UserTier.platinum: 5000,
      UserTier.diamond: 10000,
    };
  }
}

class SeasonalChallenge {
  final String id;
  final String name;
  final String description;
  final int tokenReward;
  final DateTime startDate;
  final DateTime endDate;
  final List<ChallengeTask> tasks;
  final bool isActive;
  final String? imageUrl;
  final ChallengeType type;

  SeasonalChallenge({
    required this.id,
    required this.name,
    required this.description,
    required this.tokenReward,
    required this.startDate,
    required this.endDate,
    required this.tasks,
    this.isActive = true,
    this.imageUrl,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tokenReward': tokenReward,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'isActive': isActive,
      'imageUrl': imageUrl,
      'type': type.name,
    };
  }

  factory SeasonalChallenge.fromJson(Map<String, dynamic> json) {
    return SeasonalChallenge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      tokenReward: json['tokenReward'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      tasks: (json['tasks'] as List)
          .map((t) => ChallengeTask.fromJson(t))
          .toList(),
      isActive: json['isActive'] ?? true,
      imageUrl: json['imageUrl'],
      type: ChallengeType.values.firstWhere(
        (type) => type.name == json['type'],
      ),
    );
  }
}

class ChallengeTask {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final int currentCount;
  final String taskType;
  final bool isCompleted;

  ChallengeTask({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    this.currentCount = 0,
    required this.taskType,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'taskType': taskType,
      'isCompleted': isCompleted,
    };
  }

  factory ChallengeTask.fromJson(Map<String, dynamic> json) {
    return ChallengeTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetCount: json['targetCount'],
      currentCount: json['currentCount'] ?? 0,
      taskType: json['taskType'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

enum ChallengeType {
  daily,
  weekly,
  monthly,
  seasonal,
  milestone,
}

class SampleRewards {
  static List<Reward> getSampleRewards() {
    final now = DateTime.now();
    
    return [
      Reward(
        id: 'reward_001',
        name: '20% Off Prenatal Vitamins',
        tokenCost: 50,
        category: 'Health & Wellness',
        partnerId: 'partner_pharmacy_001',
        partnerName: 'HealthCare Pharmacy',
        description: 'Get 20% discount on premium prenatal vitamins',
        type: RewardType.discount,
        discountPercentage: 20.0,
        isAvailable: true,
        terms: [
          'Valid for 30 days from redemption',
          'Cannot be combined with other offers',
          'Valid at participating locations only'
        ],
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      
      Reward(
        id: 'reward_002',
        name: 'Free Nutrition Consultation',
        tokenCost: 150,
        category: 'Consultation',
        partnerId: 'partner_nutrition_001',
        partnerName: 'Maternal Nutrition Experts',
        description: 'One-on-one consultation with certified nutritionist',
        type: RewardType.consultation,
        isAvailable: true,
        stockQuantity: 10,
        terms: [
          '45-minute session via video call',
          'Personalized meal plan included',
          'Must be scheduled within 60 days'
        ],
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      
      Reward(
        id: 'reward_003',
        name: 'Baby Care Starter Kit',
        tokenCost: 300,
        category: 'Baby Products',
        partnerId: 'partner_baby_001',
        partnerName: 'Little Angels Baby Store',
        description: 'Essential baby care items for new mothers',
        type: RewardType.freeItem,
        isAvailable: true,
        stockQuantity: 5,
        terms: [
          'Includes diapers, wipes, lotion, and more',
          'Free delivery within city limits',
          'Valid for one-time use only'
        ],
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      
      Reward(
        id: 'reward_004',
        name: 'Maternity Photoshoot',
        tokenCost: 200,
        category: 'Photography',
        partnerId: 'partner_photo_001',
        partnerName: 'Moments Photography Studio',
        description: 'Professional maternity photoshoot session',
        type: RewardType.voucher,
        isAvailable: true,
        stockQuantity: 3,
        terms: [
          '1-hour studio session',
          '10 edited digital photos included',
          'Additional prints available for purchase'
        ],
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      
      Reward(
        id: 'reward_005',
        name: 'Yoga Class Pass',
        tokenCost: 75,
        category: 'Fitness',
        partnerId: 'partner_yoga_001',
        partnerName: 'Prenatal Wellness Center',
        description: '5-class pass for prenatal yoga',
        type: RewardType.voucher,
        isAvailable: true,
        expiryDate: now.add(const Duration(days: 90)),
        terms: [
          'Valid for prenatal yoga classes only',
          'Must be used within 3 months',
          'Non-transferable'
        ],
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
