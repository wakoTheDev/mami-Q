import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/symptom_tracking_repository.dart';
export 'symptom_tracking_provider_riverpod.dart' show symptomTrackingProvider;

// This is a setup file for the riverpod symptom tracking provider
// It initializes the repository and provides the symptom tracking provider

// Create the repository provider - make sure it's properly initialized
final symptomRepositoryProvider = Provider<LocalSymptomTrackingRepository>((ref) {
  // In a real app, you would initialize this with the actual repository
  // This is a placeholder that should be replaced with actual initialization in main.dart
  throw UnimplementedError('LocalSymptomTrackingRepository must be initialized in main.dart');
});
