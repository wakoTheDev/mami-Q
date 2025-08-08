import 'dart:math';

class PregnancyUtils {
  /// Calculate pregnancy week from start date
  static int calculatePregnancyWeek(DateTime pregnancyStartDate) {
    final now = DateTime.now();
    final daysDifference = now.difference(pregnancyStartDate).inDays;
    return max(1, (daysDifference / 7).floor() + 1);
  }

  /// Calculate due date from pregnancy start date
  static DateTime calculateDueDate(DateTime pregnancyStartDate) {
    return pregnancyStartDate.add(const Duration(days: 280)); // 40 weeks
  }

  /// Calculate trimester from pregnancy week
  static int calculateTrimester(int pregnancyWeek) {
    if (pregnancyWeek <= 12) return 1;
    if (pregnancyWeek <= 27) return 2;
    return 3;
  }

  /// Get trimester name
  static String getTrimesterName(int trimester) {
    switch (trimester) {
      case 1:
        return 'First Trimester';
      case 2:
        return 'Second Trimester';
      case 3:
        return 'Third Trimester';
      default:
        return 'Unknown';
    }
  }

  /// Calculate days remaining until due date
  static int daysUntilDue(DateTime pregnancyStartDate) {
    final dueDate = calculateDueDate(pregnancyStartDate);
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  /// Get pregnancy milestone for current week
  static Map<String, String> getWeeklyMilestone(int week) {
    final milestones = {
      4: {
        'title': 'Neural Tube Development',
        'description': 'Your baby\'s neural tube is forming, which will become the brain and spinal cord.',
        'baby_size': 'Poppy seed',
        'baby_length': '2mm'
      },
      8: {
        'title': 'Major Organs Forming',
        'description': 'All major organs are beginning to develop. Your baby\'s heart is beating!',
        'baby_size': 'Raspberry',
        'baby_length': '16mm'
      },
      12: {
        'title': 'End of First Trimester',
        'description': 'Your baby\'s organs are formed and functioning. Risk of miscarriage decreases significantly.',
        'baby_size': 'Lime',
        'baby_length': '6cm'
      },
      16: {
        'title': 'Gender Can Be Determined',
        'description': 'Your baby\'s sex organs are developed enough to determine gender via ultrasound.',
        'baby_size': 'Avocado',
        'baby_length': '12cm'
      },
      20: {
        'title': 'Halfway Point',
        'description': 'You\'re halfway through! Your baby can hear sounds and may respond to music.',
        'baby_size': 'Banana',
        'baby_length': '25cm'
      },
      24: {
        'title': 'Viability Milestone',
        'description': 'Your baby has reached the age of viability and could potentially survive outside the womb.',
        'baby_size': 'Corn cob',
        'baby_length': '30cm'
      },
      28: {
        'title': 'Third Trimester Begins',
        'description': 'Your baby\'s brain is rapidly developing, and they can open and close their eyes.',
        'baby_size': 'Eggplant',
        'baby_length': '35cm'
      },
      32: {
        'title': 'Bones Hardening',
        'description': 'Your baby\'s bones are hardening, but the skull remains soft for delivery.',
        'baby_size': 'Jicama',
        'baby_length': '42cm'
      },
      36: {
        'title': 'Considered Full-Term Soon',
        'description': 'Your baby is almost ready! Lungs are maturing and preparing for breathing.',
        'baby_size': 'Romaine lettuce',
        'baby_length': '47cm'
      },
      40: {
        'title': 'Ready for Birth',
        'description': 'Your baby is fully developed and ready to meet you!',
        'baby_size': 'Watermelon',
        'baby_length': '51cm'
      },
    };

    // Find the closest milestone
    int closestWeek = milestones.keys
        .where((w) => w <= week)
        .reduce((a, b) => (week - a).abs() < (week - b).abs() ? a : b);

    return milestones[closestWeek] ?? milestones[4]!;
  }

  /// Get common symptoms for a specific trimester
  static List<String> getCommonSymptoms(int trimester) {
    switch (trimester) {
      case 1:
        return [
          'Morning sickness',
          'Fatigue',
          'Breast tenderness',
          'Frequent urination',
          'Food aversions',
          'Mood swings'
        ];
      case 2:
        return [
          'Increased energy',
          'Baby movements',
          'Back pain',
          'Constipation',
          'Heartburn',
          'Stretch marks'
        ];
      case 3:
        return [
          'Shortness of breath',
          'Swelling',
          'Braxton Hicks contractions',
          'Trouble sleeping',
          'Frequent urination',
          'Pelvic pressure'
        ];
      default:
        return [];
    }
  }

  /// Check if a symptom is concerning and requires medical attention
  static bool isConcerningSymptom(String symptom, int trimester) {
    final concerningSymptoms = [
      'severe bleeding',
      'severe abdominal pain',
      'severe headache',
      'vision changes',
      'high fever',
      'persistent vomiting',
      'no fetal movement',
      'severe swelling',
      'chest pain',
      'difficulty breathing'
    ];

    return concerningSymptoms.any((concerning) =>
        symptom.toLowerCase().contains(concerning.toLowerCase()));
  }

  /// Get recommended weight gain for trimester
  static Map<String, double> getRecommendedWeightGain(int trimester, double prePregnancyBMI) {
    double totalRecommended;
    double weeklyRecommended;

    // Determine total recommended weight gain based on pre-pregnancy BMI
    if (prePregnancyBMI < 18.5) {
      // Underweight
      totalRecommended = 15.0; // 12.5-18 kg
      weeklyRecommended = 0.5;
    } else if (prePregnancyBMI < 25) {
      // Normal weight
      totalRecommended = 12.5; // 11.5-16 kg
      weeklyRecommended = 0.4;
    } else if (prePregnancyBMI < 30) {
      // Overweight
      totalRecommended = 9.0; // 7-11.5 kg
      weeklyRecommended = 0.3;
    } else {
      // Obese
      totalRecommended = 7.0; // 5-9 kg
      weeklyRecommended = 0.2;
    }

    return {
      'total': totalRecommended,
      'weekly': weeklyRecommended,
    };
  }

  /// Format pregnancy week display
  static String formatPregnancyWeek(int week) {
    if (week > 40) return '40+ weeks';
    return '$week weeks';
  }

  /// Get pregnancy phase description
  static String getPregnancyPhase(int week) {
    if (week <= 12) return 'Early pregnancy - Focus on healthy habits and prenatal care';
    if (week <= 27) return 'Mid pregnancy - Energy returns, baby development accelerates';
    return 'Late pregnancy - Preparing for birth, final development';
  }

  /// Calculate current week of pregnancy
  static int calculateCurrentWeek(DateTime pregnancyStartDate) {
    return calculatePregnancyWeek(pregnancyStartDate);
  }
  
  /// Format date time for display
  static String formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// Get description for specific pregnancy week
  static String getWeekDescription(int week) {
    final milestones = getWeeklyMilestone(week);
    return milestones['description'] ?? 'No description available for week $week';
  }
}

class DateUtils {
  /// Format date for display
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format date with day name
  static String formatDateWithDay(DateTime date) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${dayNames[date.weekday - 1]}, ${formatDate(date)}';
  }

  /// Get time ago string
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
}

class HealthUtils {
  /// Calculate BMI
  static double calculateBMI(double weightKg, double heightM) {
    return weightKg / (heightM * heightM);
  }

  /// Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// Check if blood pressure is normal
  static String getBloodPressureCategory(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) return 'Normal';
    if (systolic < 130 && diastolic < 80) return 'Elevated';
    if (systolic < 140 || diastolic < 90) return 'High Blood Pressure Stage 1';
    return 'High Blood Pressure Stage 2';
  }

  /// Check if heart rate is normal for pregnancy
  static String getHeartRateCategory(int heartRate, bool isPregnant) {
    if (isPregnant) {
      // Pregnancy normal range is slightly higher
      if (heartRate >= 60 && heartRate <= 100) return 'Normal';
      if (heartRate < 60) return 'Low';
      return 'High';
    } else {
      if (heartRate >= 60 && heartRate <= 100) return 'Normal';
      if (heartRate < 60) return 'Low';
      return 'High';
    }
  }

  /// Get hydration recommendation
  static String getHydrationRecommendation(int pregnancyWeek) {
    if (pregnancyWeek <= 12) {
      return 'Drink 8-10 glasses of water daily. Increase if experiencing morning sickness.';
    } else if (pregnancyWeek <= 27) {
      return 'Aim for 10-12 glasses of water daily as blood volume increases.';
    } else {
      return 'Maintain 10-12 glasses daily, but monitor for swelling. Reduce before bedtime if needed.';
    }
  }
}

class ValidationUtils {
  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate phone number
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  /// Validate password strength
  static Map<String, bool> validatePassword(String password) {
    return {
      'hasMinLength': password.length >= 8,
      'hasUppercase': RegExp(r'[A-Z]').hasMatch(password),
      'hasLowercase': RegExp(r'[a-z]').hasMatch(password),
      'hasNumbers': RegExp(r'[0-9]').hasMatch(password),
      'hasSpecialChars': RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
    };
  }

  /// Check if name is valid
  static bool isValidName(String name) {
    return name.trim().length >= 2 && RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }
}

class TokenUtils {
  /// Calculate tokens for activity
  static int calculateTokensForActivity(String activityType, Map<String, dynamic> data) {
    switch (activityType.toLowerCase()) {
      case 'symptom_logging':
        return 5;
      case 'meal_preparation':
        return 10;
      case 'exercise':
        return 15;
      case 'appointment_attendance':
        return 20;
      case 'community_post':
        return 3;
      case 'recipe_sharing':
        return 8;
      case 'health_goal_completion':
        return 12;
      case 'referral':
        return 50;
      case 'weekly_challenge':
        return 25;
      default:
        return 1;
    }
  }

  /// Get token multiplier for streak
  static double getStreakMultiplier(int streakDays) {
    if (streakDays >= 30) return 2.0;
    if (streakDays >= 14) return 1.5;
    if (streakDays >= 7) return 1.2;
    return 1.0;
  }

  /// Format token display
  static String formatTokenCount(int tokens) {
    if (tokens >= 1000000) {
      return '${(tokens / 1000000).toStringAsFixed(1)}M';
    } else if (tokens >= 1000) {
      return '${(tokens / 1000).toStringAsFixed(1)}K';
    }
    return tokens.toString();
  }
}
