import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/symptom_entry.dart';

abstract class SymptomTrackingRepository {
  Future<List<SymptomEntry>> getAllSymptomEntries(String userId);
  Future<List<SymptomEntry>> getSymptomEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<SymptomEntry?> getSymptomEntryByDate(String userId, DateTime date);
  Future<void> saveSymptomEntry(SymptomEntry entry);
  Future<void> updateSymptomEntry(SymptomEntry entry);
  Future<void> deleteSymptomEntry(String entryId);
  Future<List<SymptomEntry>> getWeeklySymptomSummary(
    String userId,
    int pregnancyWeek,
  );
  Future<Map<String, dynamic>> getSymptomTrends(
    String userId,
    int numberOfWeeks,
  );
  Future<List<String>> getConcerningSymptoms(String userId);
  Future<void> syncWithServer();
}

class LocalSymptomTrackingRepository implements SymptomTrackingRepository {
  static const String _symptomsKey = 'symptom_entries';
  late SharedPreferences _prefs;

  LocalSymptomTrackingRepository._();

  static LocalSymptomTrackingRepository? _instance;
  
  static Future<LocalSymptomTrackingRepository> getInstance() async {
    if (_instance == null) {
      _instance = LocalSymptomTrackingRepository._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<SymptomEntry>> getAllSymptomEntries(String userId) async {
    final symptomsJson = _prefs.getStringList(_symptomsKey) ?? [];
    final symptoms = symptomsJson
        .map((json) => SymptomEntry.fromJson(jsonDecode(json)))
        .where((entry) => entry.userId == userId)
        .toList();
    
    symptoms.sort((a, b) => b.date.compareTo(a.date));
    return symptoms;
  }

  @override
  Future<List<SymptomEntry>> getSymptomEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allEntries = await getAllSymptomEntries(userId);
    return allEntries
        .where((entry) =>
            entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            entry.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  @override
  Future<SymptomEntry?> getSymptomEntryByDate(String userId, DateTime date) async {
    final allEntries = await getAllSymptomEntries(userId);
    try {
      return allEntries.firstWhere((entry) =>
          entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveSymptomEntry(SymptomEntry entry) async {
    final symptomsJson = _prefs.getStringList(_symptomsKey) ?? [];
    symptomsJson.add(jsonEncode(entry.toJson()));
    await _prefs.setStringList(_symptomsKey, symptomsJson);
  }

  @override
  Future<void> updateSymptomEntry(SymptomEntry entry) async {
    final symptomsJson = _prefs.getStringList(_symptomsKey) ?? [];
    final updatedEntry = entry.copyWith(updatedAt: DateTime.now());
    
    final index = symptomsJson.indexWhere((json) {
      final existingEntry = SymptomEntry.fromJson(jsonDecode(json));
      return existingEntry.id == entry.id;
    });

    if (index != -1) {
      symptomsJson[index] = jsonEncode(updatedEntry.toJson());
      await _prefs.setStringList(_symptomsKey, symptomsJson);
    }
  }

  @override
  Future<void> deleteSymptomEntry(String entryId) async {
    final symptomsJson = _prefs.getStringList(_symptomsKey) ?? [];
    symptomsJson.removeWhere((json) {
      final entry = SymptomEntry.fromJson(jsonDecode(json));
      return entry.id == entryId;
    });
    await _prefs.setStringList(_symptomsKey, symptomsJson);
  }

  @override
  Future<List<SymptomEntry>> getWeeklySymptomSummary(
    String userId,
    int pregnancyWeek,
  ) async {
    final allEntries = await getAllSymptomEntries(userId);
    return allEntries.where((entry) => entry.pregnancyWeek == pregnancyWeek).toList();
  }

  @override
  Future<Map<String, dynamic>> getSymptomTrends(
    String userId,
    int numberOfWeeks,
  ) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: numberOfWeeks * 7));
    final entries = await getSymptomEntriesByDateRange(userId, startDate, endDate);

    final trends = <String, List<double>>{};
    final moodTrends = <String, int>{};
    final energyTrends = <double>[];
    final sleepTrends = <double>[];

    for (final entry in entries) {
      // Track symptom severity trends
      entry.symptoms.forEach((symptomName, data) {
        if (data is Map && data.containsKey('severity')) {
          if (!trends.containsKey(symptomName)) {
            trends[symptomName] = [];
          }
          trends[symptomName]!.add(data['severity'].toDouble());
        }
      });

      // Track mood trends
      moodTrends[entry.mood] = (moodTrends[entry.mood] ?? 0) + 1;

      // Track energy and sleep trends
      energyTrends.add(entry.energyLevel);
      sleepTrends.add(entry.sleepQuality);
    }

    return {
      'symptomTrends': trends,
      'moodTrends': moodTrends,
      'averageEnergy': energyTrends.isNotEmpty
          ? energyTrends.reduce((a, b) => a + b) / energyTrends.length
          : 0.0,
      'averageSleep': sleepTrends.isNotEmpty
          ? sleepTrends.reduce((a, b) => a + b) / sleepTrends.length
          : 0.0,
      'totalEntries': entries.length,
    };
  }

  @override
  Future<List<String>> getConcerningSymptoms(String userId) async {
    final allEntries = await getAllSymptomEntries(userId);
    final concerningSymptoms = <String>[];

    // Define concerning symptom patterns
    final concerningPatterns = {
      'Severe Headache': (Map<String, dynamic> symptom) =>
          symptom['severity'] != null && symptom['severity'] >= 8,
      'Persistent Vomiting': (Map<String, dynamic> symptom) =>
          symptom['frequency'] != null && symptom['frequency'] >= 5,
      'High Blood Pressure Signs': (Map<String, dynamic> symptom) =>
          symptom['severity'] != null && symptom['severity'] >= 7,
      'Severe Swelling': (Map<String, dynamic> symptom) =>
          symptom['severity'] != null && symptom['severity'] >= 8,
      'Intense Contractions': (Map<String, dynamic> symptom) =>
          symptom['frequency'] != null && symptom['frequency'] >= 6,
    };

    for (final entry in allEntries.take(7)) { // Check last 7 days
      entry.symptoms.forEach((symptomName, symptomData) {
        if (symptomData is Map<String, dynamic>) {
          concerningPatterns.forEach((pattern, checker) {
            if (symptomName.toLowerCase().contains(pattern.toLowerCase()) ||
                checker(symptomData)) {
              if (!concerningSymptoms.contains(pattern)) {
                concerningSymptoms.add(pattern);
              }
            }
          });
        }
      });

      // Check for concerning patterns
      if (entry.energyLevel <= 2.0) {
        concerningSymptoms.add('Extremely Low Energy');
      }
      if (entry.sleepQuality <= 2.0) {
        concerningSymptoms.add('Poor Sleep Quality');
      }
      if (entry.mood == 'Very Sad' || entry.mood == 'Depressed') {
        concerningSymptoms.add('Concerning Mood Changes');
      }
    }

    return concerningSymptoms.toSet().toList();
  }

  @override
  Future<void> syncWithServer() async {
    // TODO: Implement server sync functionality
    // This would typically involve:
    // 1. Getting unsynced entries (isSynced = false)
    // 2. Sending them to the server
    // 3. Updating the isSynced flag
    // 4. Handling conflicts and merging server data
    
    final symptomsJson = _prefs.getStringList(_symptomsKey) ?? [];
    final updatedSymptoms = <String>[];

    for (final json in symptomsJson) {
      final entry = SymptomEntry.fromJson(jsonDecode(json));
      if (!entry.isSynced) {
        // Simulate sync by marking as synced
        final syncedEntry = entry.copyWith(isSynced: true);
        updatedSymptoms.add(jsonEncode(syncedEntry.toJson()));
      } else {
        updatedSymptoms.add(json);
      }
    }

    await _prefs.setStringList(_symptomsKey, updatedSymptoms);
  }

  // Methods for Riverpod provider
  Future<List<SymptomEntry>> getAllSymptoms() async {
    return getAllSymptomEntries('current_user_id'); // Use a default user ID or from auth
  }
  
  Future<void> addSymptom(SymptomEntry symptom) async {
    return saveSymptomEntry(symptom);
  }
  
  Future<void> updateSymptom(SymptomEntry symptom) async {
    return updateSymptomEntry(symptom);
  }
  
  Future<void> deleteSymptom(String symptomId) async {
    return deleteSymptomEntry(symptomId);
  }
}
