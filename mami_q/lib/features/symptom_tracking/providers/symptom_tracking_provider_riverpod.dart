import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/symptom_entry.dart';
import '../repositories/symptom_tracking_repository.dart';

// Provider for the repository
final symptomRepositoryProvider = Provider<LocalSymptomTrackingRepository>((ref) {
  throw UnimplementedError('Repository should be initialized in main');
});

// Provider for the symptom tracking notifier
final symptomTrackingProvider = StateNotifierProvider<SymptomTrackingNotifier, SymptomTrackingState>((ref) {
  final repository = ref.watch(symptomRepositoryProvider);
  return SymptomTrackingNotifier(repository);
});

// State class for symptom tracking
class SymptomTrackingState {
  final List<SymptomEntry> symptoms;
  final List<SymptomEntry> filteredSymptoms;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? selectedCategory;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  const SymptomTrackingState({
    this.symptoms = const [],
    this.filteredSymptoms = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategory,
    this.filterStartDate,
    this.filterEndDate,
  });

  SymptomTrackingState copyWith({
    List<SymptomEntry>? symptoms,
    List<SymptomEntry>? filteredSymptoms,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedCategory,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
  }) {
    return SymptomTrackingState(
      symptoms: symptoms ?? this.symptoms,
      filteredSymptoms: filteredSymptoms ?? this.filteredSymptoms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
    );
  }

  // Helper methods
  List<SymptomEntry> getTodaysSymptoms() {
    final today = DateTime.now();
    return symptoms.where((symptom) {
      return symptom.date.year == today.year &&
             symptom.date.month == today.month &&
             symptom.date.day == today.day;
    }).toList();
  }

  List<SymptomEntry> getThisWeeksSymptoms() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return symptoms.where((symptom) {
      return symptom.date.isAfter(weekStart) && symptom.date.isBefore(weekEnd);
    }).toList();
  }

  Map<String, List<SymptomEntry>> getSymptomsByCategory() {
    final Map<String, List<SymptomEntry>> categoryMap = {};
    
    for (final symptom in symptoms) {
      // Extract category from symptoms map keys
      for (final category in symptom.symptoms.keys) {
        if (!categoryMap.containsKey(category)) {
          categoryMap[category] = [];
        }
        categoryMap[category]!.add(symptom);
      }
    }
    
    return categoryMap;
  }

  Map<String, int> getSymptomFrequency() {
    final Map<String, int> frequency = {};
    
    for (final symptom in symptoms) {
      for (final symptomName in symptom.symptoms.keys) {
        frequency[symptomName] = (frequency[symptomName] ?? 0) + 1;
      }
    }
    
    return frequency;
  }

  double getAverageSeverity() {
    if (symptoms.isEmpty) return 0.0;
    
    double totalSeverity = 0;
    int count = 0;
    
    for (final symptom in symptoms) {
      for (final entry in symptom.symptoms.entries) {
        if (entry.value is Map && (entry.value as Map).containsKey('severity')) {
          totalSeverity += (entry.value['severity'] as num).toDouble();
          count++;
        }
      }
    }
    
    return count > 0 ? totalSeverity / count : 0.0;
  }

  List<SymptomEntry> getSeverityTrend(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return symptoms.where((symptom) => symptom.date.isAfter(cutoffDate)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}

// Notifier class for symptom tracking
class SymptomTrackingNotifier extends StateNotifier<SymptomTrackingState> {
  final LocalSymptomTrackingRepository _repository;

  SymptomTrackingNotifier(this._repository) : super(const SymptomTrackingState()) {
    // Load cached symptoms from local storage when initializing
    _loadFromLocalStorage();
  }

  // Load symptoms from repository
  Future<void> loadSymptoms() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final symptoms = await _repository.getAllSymptoms();
      symptoms.sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
      
      state = state.copyWith(
        symptoms: symptoms,
        filteredSymptoms: symptoms,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load symptoms: ${e.toString()}',
      );
    }
  }

  // Add new symptom
  Future<void> addSymptom(SymptomEntry symptom) async {
    try {
      await _repository.addSymptom(symptom);
      
      final updatedSymptoms = [symptom, ...state.symptoms];
      updatedSymptoms.sort((a, b) => b.date.compareTo(a.date));
      
      state = state.copyWith(
        symptoms: updatedSymptoms,
        filteredSymptoms: _applyFilters(updatedSymptoms),
      );
      
      // Save to local storage for persistence
      await _saveToLocalStorage();
      
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to add symptom: ${e.toString()}',
      );
    }
  }

  // Update existing symptom
  Future<void> updateSymptom(SymptomEntry symptom) async {
    try {
      await _repository.updateSymptom(symptom);
      
      final updatedSymptoms = state.symptoms.map((s) {
        return s.id == symptom.id ? symptom : s;
      }).toList();
      
      updatedSymptoms.sort((a, b) => b.date.compareTo(a.date));
      
      state = state.copyWith(
        symptoms: updatedSymptoms,
        filteredSymptoms: _applyFilters(updatedSymptoms),
      );
      
      await _saveToLocalStorage();
      
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update symptom: ${e.toString()}',
      );
    }
  }

  // Delete symptom
  Future<void> deleteSymptom(String symptomId) async {
    try {
      await _repository.deleteSymptom(symptomId);
      
      final updatedSymptoms = state.symptoms.where((s) => s.id != symptomId).toList();
      
      state = state.copyWith(
        symptoms: updatedSymptoms,
        filteredSymptoms: _applyFilters(updatedSymptoms),
      );
      
      await _saveToLocalStorage();
      
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete symptom: ${e.toString()}',
      );
    }
  }

  // Search symptoms
  void searchSymptoms(String query) {
    state = state.copyWith(searchQuery: query);
    
    final filtered = _applyFilters(state.symptoms);
    state = state.copyWith(filteredSymptoms: filtered);
  }

  // Filter by category
  void filterByCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    
    final filtered = _applyFilters(state.symptoms);
    state = state.copyWith(filteredSymptoms: filtered);
  }

  // Filter by date range
  void filterByDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      filterStartDate: startDate,
      filterEndDate: endDate,
    );
    
    final filtered = _applyFilters(state.symptoms);
    state = state.copyWith(filteredSymptoms: filtered);
  }

  // Clear all filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedCategory: null,
      filterStartDate: null,
      filterEndDate: null,
      filteredSymptoms: state.symptoms,
    );
  }

  // Export symptoms to PDF
  Future<void> exportToPDF() async {
    try {
      // TODO: Implement PDF export functionality
      // This would generate a PDF report of symptoms
      print('Exporting ${state.symptoms.length} symptoms to PDF...');
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to export PDF: ${e.toString()}',
      );
    }
  }

  // Export symptoms to CSV
  Future<void> exportToCSV() async {
    try {
      // TODO: Implement CSV export functionality
      print('Exporting ${state.symptoms.length} symptoms to CSV...');
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to export CSV: ${e.toString()}',
      );
    }
  }

  // Generate health report
  Map<String, dynamic> generateHealthReport() {
    final symptoms = state.symptoms;
    
    return {
      'totalSymptoms': symptoms.length,
      'averageSeverity': state.getAverageSeverity(),
      'mostCommonSymptoms': state.getSymptomFrequency(),
      'symptomsByCategory': state.getSymptomsByCategory(),
      'thisWeekSymptoms': state.getThisWeeksSymptoms().length,
      'todaySymptoms': state.getTodaysSymptoms().length,
      'severityTrend': state.getSeverityTrend(30),
    };
  }

  // Check for warning patterns
  List<String> checkWarningPatterns() {
    final warnings = <String>[];
    final recentSymptoms = state.getSeverityTrend(7);
    
    // Check for high severity symptoms
    final highSeveritySymptoms = recentSymptoms.where((s) {
      bool hasHighSeverity = false;
      for (final entry in s.symptoms.entries) {
        if (entry.value is Map && 
            (entry.value as Map).containsKey('severity') && 
            (entry.value['severity'] as num) >= 8) {
          hasHighSeverity = true;
          break;
        }
      }
      return hasHighSeverity;
    }).toList();
    
    if (highSeveritySymptoms.length >= 3) {
      warnings.add('Multiple high-severity symptoms in the past week. Consider consulting your healthcare provider.');
    }
    
    // Check for unusual frequency
    final todaySymptoms = state.getTodaysSymptoms();
    if (todaySymptoms.length >= 5) {
      warnings.add('Unusually high number of symptoms today. Monitor closely.');
    }
    
    // Check for concerning symptom combinations
    final todaySymptomTypes = <String>[];
    for (final symptom in todaySymptoms) {
      todaySymptomTypes.addAll(symptom.symptoms.keys);
    }
    
    if (todaySymptomTypes.contains('bleeding') && todaySymptomTypes.contains('cramping')) {
      warnings.add('URGENT: Bleeding and cramping detected. Contact your healthcare provider immediately.');
    }
    
    return warnings;
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Private helper methods
  List<SymptomEntry> _applyFilters(List<SymptomEntry> symptoms) {
    var filtered = symptoms;
    
    // Apply search query
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered.where((symptom) {
        // Search in symptom names (keys)
        final hasMatchingSymptomName = symptom.symptoms.keys.any(
          (key) => key.toLowerCase().contains(state.searchQuery.toLowerCase())
        );
        
        // Search in notes
        final hasMatchingNotes = symptom.notes?.toLowerCase().contains(state.searchQuery.toLowerCase()) ?? false;
        
        // Search in concerns
        final hasMatchingConcern = symptom.concerns.any(
          (concern) => concern.toLowerCase().contains(state.searchQuery.toLowerCase())
        );
        
        // Search in mood
        final hasMatchingMood = symptom.mood.toLowerCase().contains(state.searchQuery.toLowerCase());
        
        return hasMatchingSymptomName || hasMatchingNotes || hasMatchingConcern || hasMatchingMood;
      }).toList();
    }
    
    // Apply category filter
    if (state.selectedCategory != null) {
      filtered = filtered.where((symptom) {
        return symptom.symptoms.keys.contains(state.selectedCategory);
      }).toList();
    }
    
    // Apply date range filter
    if (state.filterStartDate != null && state.filterEndDate != null) {
      filtered = filtered.where((symptom) {
        return symptom.date.isAfter(state.filterStartDate!) &&
               symptom.date.isBefore(state.filterEndDate!.add(const Duration(days: 1)));
      }).toList();
    }
    
    return filtered;
  }

  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final symptomsJson = state.symptoms.map((s) => s.toJson()).toList();
      await prefs.setString('cached_symptoms', json.encode(symptomsJson));
    } catch (e) {
      print('Failed to save symptoms to local storage: $e');
    }
  }

  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final symptomsString = prefs.getString('cached_symptoms');
      
      if (symptomsString != null) {
        final symptomsJson = json.decode(symptomsString) as List;
        final symptoms = symptomsJson
            .map((s) => SymptomEntry.fromJson(s as Map<String, dynamic>))
            .toList();
        
        if (symptoms.isNotEmpty) {
          symptoms.sort((a, b) => b.date.compareTo(a.date));
          
          state = state.copyWith(
            symptoms: symptoms,
            filteredSymptoms: symptoms,
          );
        }
      }
    } catch (e) {
      print('Failed to load symptoms from local storage: $e');
    }
  }
}
