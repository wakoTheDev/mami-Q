import 'package:flutter/foundation.dart';
import '../models/symptom_entry.dart';
import '../repositories/symptom_tracking_repository.dart';

class SymptomTrackingProvider extends ChangeNotifier {
  final SymptomTrackingRepository _repository;
  
  List<SymptomEntry> _symptomEntries = [];
  SymptomEntry? _todayEntry;
  Map<String, dynamic> _trends = {};
  List<String> _concerningSymptoms = [];
  bool _isLoading = false;
  String? _error;

  SymptomTrackingProvider(this._repository);

  // Getters
  List<SymptomEntry> get symptomEntries => _symptomEntries;
  SymptomEntry? get todayEntry => _todayEntry;
  Map<String, dynamic> get trends => _trends;
  List<String> get concerningSymptoms => _concerningSymptoms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize data
  Future<void> initialize(String userId) async {
    _setLoading(true);
    try {
      await loadSymptomEntries(userId);
      await loadTodayEntry(userId);
      await loadTrends(userId);
      await loadConcerningSymptoms(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Load all symptom entries
  Future<void> loadSymptomEntries(String userId) async {
    try {
      _symptomEntries = await _repository.getAllSymptomEntries(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load today's entry
  Future<void> loadTodayEntry(String userId) async {
    try {
      _todayEntry = await _repository.getSymptomEntryByDate(userId, DateTime.now());
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load symptom trends
  Future<void> loadTrends(String userId, {int weeks = 4}) async {
    try {
      _trends = await _repository.getSymptomTrends(userId, weeks);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load concerning symptoms
  Future<void> loadConcerningSymptoms(String userId) async {
    try {
      _concerningSymptoms = await _repository.getConcerningSymptoms(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Save a new symptom entry
  Future<bool> saveSymptomEntry(SymptomEntry entry) async {
    _setLoading(true);
    try {
      await _repository.saveSymptomEntry(entry);
      _symptomEntries.insert(0, entry);
      
      // Update today's entry if it's for today
      final today = DateTime.now();
      if (entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day) {
        _todayEntry = entry;
      }
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing symptom entry
  Future<bool> updateSymptomEntry(SymptomEntry entry) async {
    _setLoading(true);
    try {
      await _repository.updateSymptomEntry(entry);
      
      final index = _symptomEntries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _symptomEntries[index] = entry;
      }
      
      // Update today's entry if it's for today
      final today = DateTime.now();
      if (entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day) {
        _todayEntry = entry;
      }
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a symptom entry
  Future<bool> deleteSymptomEntry(String entryId) async {
    _setLoading(true);
    try {
      await _repository.deleteSymptomEntry(entryId);
      _symptomEntries.removeWhere((entry) => entry.id == entryId);
      
      if (_todayEntry?.id == entryId) {
        _todayEntry = null;
      }
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get entries for a specific date range
  Future<List<SymptomEntry>> getEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _repository.getSymptomEntriesByDateRange(
        userId,
        startDate,
        endDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get weekly summary
  Future<List<SymptomEntry>> getWeeklySummary(
    String userId,
    int pregnancyWeek,
  ) async {
    try {
      return await _repository.getWeeklySymptomSummary(userId, pregnancyWeek);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Sync with server
  Future<void> syncWithServer() async {
    _setLoading(true);
    try {
      await _repository.syncWithServer();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get symptom severity trend for a specific symptom
  List<double> getSymptomTrend(String symptomName) {
    if (_trends['symptomTrends'] != null &&
        _trends['symptomTrends'][symptomName] != null) {
      return List<double>.from(_trends['symptomTrends'][symptomName]);
    }
    return [];
  }

  // Check if user has concerning symptoms
  bool hasConcerningSymptoms() {
    return _concerningSymptoms.isNotEmpty;
  }

  // Get most frequent symptoms
  List<String> getMostFrequentSymptoms({int limit = 5}) {
    final symptomCounts = <String, int>{};
    
    for (final entry in _symptomEntries) {
      for (final symptom in entry.symptoms.keys) {
        symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
      }
    }

    final sortedSymptoms = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedSymptoms
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  // Calculate pregnancy week from start date
  static int calculatePregnancyWeek(DateTime pregnancyStartDate) {
    final now = DateTime.now();
    final daysDifference = now.difference(pregnancyStartDate).inDays;
    return (daysDifference / 7).floor() + 1;
  }

  // Get mood distribution
  Map<String, int> getMoodDistribution({int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentEntries = _symptomEntries
        .where((entry) => entry.date.isAfter(cutoffDate))
        .toList();

    final moodCounts = <String, int>{};
    for (final entry in recentEntries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return moodCounts;
  }

  // Get average energy and sleep quality
  Map<String, double> getAverageWellbeing({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentEntries = _symptomEntries
        .where((entry) => entry.date.isAfter(cutoffDate))
        .toList();

    if (recentEntries.isEmpty) {
      return {'energy': 0.0, 'sleep': 0.0};
    }

    final totalEnergy = recentEntries
        .map((entry) => entry.energyLevel)
        .reduce((a, b) => a + b);
    final totalSleep = recentEntries
        .map((entry) => entry.sleepQuality)
        .reduce((a, b) => a + b);

    return {
      'energy': totalEnergy / recentEntries.length,
      'sleep': totalSleep / recentEntries.length,
    };
  }
}
