import 'package:flutter/material.dart';
import '../models/symptom_entry.dart';

/// Utility class to help extract data from SymptomEntry objects
class SymptomUtils {
  /// Extract the primary title/name of the symptom entry
  static String getSymptomTitle(SymptomEntry entry) {
    if (entry.symptoms.isEmpty) {
      return 'Untitled';
    }
    return entry.symptoms.keys.first;
  }
  
  /// Get the severity of a symptom (assuming it's stored in the symptoms map)
  static double getSymptomSeverity(SymptomEntry entry) {
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
  
  /// Get the category of the symptom entry
  static String getSymptomCategory(SymptomEntry entry) {
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
  
  /// Get the description of the symptom
  static String getSymptomDescription(SymptomEntry entry) {
    // First try to get description from the symptoms map
    for (final symptomData in entry.symptoms.values) {
      if (symptomData is Map && symptomData.containsKey('description')) {
        return symptomData['description'] as String;
      }
    }
    
    // Fallback to notes
    return entry.notes ?? '';
  }
  
  /// Get the severity color based on level
  static getColorForSeverity(double severity) {
    if (severity >= 8) {
      return const Color(0xFFE57373); // Red
    } else if (severity >= 5) {
      return const Color(0xFFFFB74D); // Orange
    } else if (severity >= 3) {
      return const Color(0xFFFFD54F); // Yellow
    } else {
      return const Color(0xFF81C784); // Green
    }
  }
}
