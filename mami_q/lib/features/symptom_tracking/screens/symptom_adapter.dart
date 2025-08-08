import 'package:flutter/material.dart';
import '../models/symptom_entry.dart';

/// Adapter class to help work with SymptomEntry objects in the UI
/// This creates a consistent interface for the UI components 
/// even if the underlying model changes
class SymptomAdapter {
  final SymptomEntry entry;

  SymptomAdapter(this.entry);

  // Get a title for the symptom (using the first symptom key)
  String get title {
    if (entry.symptoms.isEmpty) {
      return 'Untitled';
    }
    return entry.symptoms.keys.first;
  }

  // Get the severity value (first found in the symptoms map)
  double get severity {
    if (entry.symptoms.isEmpty) {
      return 0.0;
    }
    
    for (final symptomData in entry.symptoms.values) {
      if (symptomData is Map && symptomData.containsKey('severity')) {
        return (symptomData['severity'] as num).toDouble();
      }
    }
    
    return 0.0;
  }

  // Get the category of the symptom
  String get category {
    if (entry.symptoms.isEmpty) {
      return 'Other';
    }
    
    // First try to get category from the symptoms map
    for (final symptomData in entry.symptoms.values) {
      if (symptomData is Map && symptomData.containsKey('category')) {
        return symptomData['category'] as String;
      }
    }
    
    // Fallback to the first symptom name
    return entry.symptoms.keys.first;
  }

  // Get a description for the symptom
  String get description {
    // First try to get description from the symptoms map
    for (final symptomData in entry.symptoms.values) {
      if (symptomData is Map && symptomData.containsKey('description')) {
        return symptomData['description'] as String;
      }
    }
    
    // Fallback to notes
    return entry.notes ?? '';
  }

  // Get the frequency of the symptom
  int get frequency {
    for (final symptomData in entry.symptoms.values) {
      if (symptomData is Map && symptomData.containsKey('frequency')) {
        return (symptomData['frequency'] as num).toInt();
      }
    }
    
    return 0;
  }
  
  // Get the color for the severity
  Color getColor() {
    if (severity >= 8) {
      return Colors.red;
    } else if (severity >= 5) {
      return Colors.orange;
    } else if (severity >= 3) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
}

// Extension method to make it easier to use with lists
extension SymptomEntryListExtension on List<SymptomEntry> {
  List<SymptomAdapter> get adapters => map((e) => SymptomAdapter(e)).toList();
}
