import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/healthcare_facility.dart';

// Repository provider
final facilityRepositoryProvider = Provider<FacilityRepository>((ref) {
  return FacilityRepository();
});

// Healthcare facilities provider
final healthcareFacilitiesProvider = AsyncNotifierProvider<FacilityNotifier, List<HealthcareFacility>>(
  () => FacilityNotifier(),
);

class FacilityNotifier extends AsyncNotifier<List<HealthcareFacility>> {
  @override
  Future<List<HealthcareFacility>> build() async {
    final repository = ref.watch(facilityRepositoryProvider);
    return await repository.getFacilities();
  }

  Future<void> addFacility(HealthcareFacility facility) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(facilityRepositoryProvider);
      await repository.saveFacility(facility);
      
      // Refresh the list
      final updatedFacilities = await repository.getFacilities();
      state = AsyncValue.data(updatedFacilities);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateFacility(HealthcareFacility facility) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(facilityRepositoryProvider);
      await repository.saveFacility(facility);
      
      // Refresh the list
      final updatedFacilities = await repository.getFacilities();
      state = AsyncValue.data(updatedFacilities);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteFacility(String facilityId) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(facilityRepositoryProvider);
      await repository.deleteFacility(facilityId);
      
      // Refresh the list
      final updatedFacilities = await repository.getFacilities();
      state = AsyncValue.data(updatedFacilities);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class FacilityRepository {
  static const String _facilitiesKey = 'healthcare_facilities';
  static const String _favoriteFacilitiesKey = 'favorite_healthcare_facilities';

  Map<String, String> get contactInfo => {
        'phone': '+254 57 234 5678',
        'email': 'info@healthcare.com',
        'website': 'www.healthcare.com',
      };

  // Get all facilities
  Future<List<HealthcareFacility>> getFacilities() async {
    final prefs = await SharedPreferences.getInstance();
    final facilitiesJson = prefs.getStringList(_facilitiesKey) ?? [];
    
    if (facilitiesJson.isEmpty) {
      // Return sample data if no facilities exist
      return _getSampleFacilities();
    }
    
    try {
      return facilitiesJson
          .map((jsonString) => HealthcareFacility.fromJson(json.decode(jsonString)))
          .toList();
    } catch (e) {
      // Return sample data if there's an error parsing the stored data
      print('Error loading facilities: $e');
      return _getSampleFacilities();
    }
  }

  // Get facility by ID
  Future<HealthcareFacility?> getFacilityById(String id) async {
    final facilities = await getFacilities();
    try {
      return facilities.firstWhere((facility) => facility.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get facilities by type
  Future<List<HealthcareFacility>> getFacilitiesByType(String type) async {
    final allFacilities = await getFacilities();
    return allFacilities.where((facility) => facility.type == type).toList();
  }

  // Save facility
  Future<void> saveFacility(HealthcareFacility facility) async {
    final prefs = await SharedPreferences.getInstance();
    final facilitiesJson = prefs.getStringList(_facilitiesKey) ?? [];
    
    // Remove existing facility with same ID if it exists
    facilitiesJson.removeWhere((jsonString) {
      try {
        final existingFacility = HealthcareFacility.fromJson(json.decode(jsonString));
        return existingFacility.id == facility.id;
      } catch (e) {
        return false;
      }
    });
    
    // Add updated facility
    facilitiesJson.add(json.encode(facility.toJson()));
    
    // Save back to shared preferences
    await prefs.setStringList(_facilitiesKey, facilitiesJson);
  }

  // Delete facility
  Future<void> deleteFacility(String facilityId) async {
    final prefs = await SharedPreferences.getInstance();
    final facilitiesJson = prefs.getStringList(_facilitiesKey) ?? [];
    
    // Remove facility with matching ID
    facilitiesJson.removeWhere((jsonString) {
      try {
        final facility = HealthcareFacility.fromJson(json.decode(jsonString));
        return facility.id == facilityId;
      } catch (e) {
        return false;
      }
    });
    
    // Save back to shared preferences
    await prefs.setStringList(_facilitiesKey, facilitiesJson);
  }

  // Get favorite facilities
  Future<List<String>> getFavoriteFacilityIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteFacilitiesKey) ?? [];
  }

  // Add to favorites
  Future<void> addToFavorites(String facilityId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList(_favoriteFacilitiesKey) ?? [];
    
    if (!favoriteIds.contains(facilityId)) {
      favoriteIds.add(facilityId);
      await prefs.setStringList(_favoriteFacilitiesKey, favoriteIds);
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String facilityId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList(_favoriteFacilitiesKey) ?? [];
    
    favoriteIds.remove(facilityId);
    await prefs.setStringList(_favoriteFacilitiesKey, favoriteIds);
  }

  // Get sample facilities
  List<HealthcareFacility> _getSampleFacilities() {
    return [
      HealthcareFacility(
        id: 'facility-1',
        name: 'Maternal Health Center',
        type: 'Hospital',
        address: '123 Main St',
        imageUrl: 'assets/images/default_facility.png',
        city: 'Nairobi',
        state: 'Nairobi County',
        zipCode: '00100',
        phoneNumber: '+254 20 123 4567',
        email: 'info@maternalhealth.co.ke',
        website: 'www.maternalhealth.co.ke',
        latitude: -1.2921,
        longitude: 36.8219,
        services: [
          'Prenatal Care',
          'Labor & Delivery',
          'Ultrasound',
          'High-Risk Pregnancy Care',
          'Neonatal Care',
          'Lactation Support',
        ],
        specialists: [
          'Dr. Sarah Mwangi - OB/GYN',
          'Dr. John Kamau - Perinatologist',
          'Dr. Mary Odhiambo - Neonatologist',
          'Jane Achieng - Midwife',
        ],
        rating: 4.8,
        reviews: [
          FacilityReview(
          id: 'review-1',
            userId: 'user-123',
            userName: 'Elizabeth W.',
            rating: 5.0,
            comment: 'Excellent care throughout my pregnancy. The staff was very attentive and professional.',
            facilityId: 'facility-1',
            visitDate: DateTime.now().subtract(const Duration(days: 35)),
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
          FacilityReview(
            id: 'review-2',
            userId: 'user-456',
            userName: 'Grace M.',
            rating: 4.5,
            comment: 'Great doctors, though sometimes the waiting times can be long.',
            facilityId: 'facility-1',
            visitDate: DateTime.now().subtract(const Duration(days: 50)),
            createdAt: DateTime.now().subtract(const Duration(days: 45)),
          ),
        ],
        operatingHours: {
          'Monday': '8:00 AM - 5:00 PM',
          'Tuesday': '8:00 AM - 5:00 PM',
          'Wednesday': '8:00 AM - 5:00 PM',
          'Thursday': '8:00 AM - 5:00 PM',
          'Friday': '8:00 AM - 5:00 PM',
          'Saturday': '9:00 AM - 1:00 PM',
          'Sunday': 'Closed',
        },
        description: 'A leading maternal health center providing comprehensive care for pregnant women. Our team of specialists ensures the best care for both mother and baby throughout pregnancy and beyond.',
        location: GeoPoint(latitude: -1.2921, longitude: 36.8219),
        contactInfo: {},
        workingHours: [],
        acceptedInsurance: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      HealthcareFacility(
        id: 'facility-2',
        name: 'Community Birth Center',
        type: 'Birth Center',
        address: '456 Oak Road',
        imageUrl: 'assets/images/default_facility.png',
        city: 'Mombasa',
        state: 'Mombasa County',
        zipCode: '80100',
        phoneNumber: '+254 41 567 8901',
        email: 'contact@communitybirthcenter.co.ke',
        website: 'www.communitybirthcenter.co.ke',
        latitude: -4.0435,
        longitude: 39.6682,
        services: [
          'Natural Birth',
          'Water Birth',
          'Prenatal Education',
          'Postpartum Care',
          'Breastfeeding Support',
          'Childbirth Classes',
        ],
        specialists: [
          'Nancy Auma - Certified Midwife',
          'James Omondi - Birthing Specialist',
          'Ruth Kimani - Lactation Consultant',
        ],
        reviews: [
          FacilityReview(
            id: 'review-3',
            userId: 'user-789',
            userName: 'Fatima A.',
            rating: 5.0,
            comment: 'I had an amazing natural birth experience here. The midwives were supportive and knowledgeable.',
            facilityId: 'facility-2',
            visitDate: DateTime.now().subtract(const Duration(days: 65)),
            createdAt: DateTime.now().subtract(const Duration(days: 60)),
          ),
        ],
        operatingHours: {
          'Monday': '9:00 AM - 4:00 PM',
          'Tuesday': '9:00 AM - 4:00 PM',
          'Wednesday': '9:00 AM - 4:00 PM',
          'Thursday': '9:00 AM - 4:00 PM',
          'Friday': '9:00 AM - 4:00 PM',
          'Saturday': '10:00 AM - 2:00 PM',
          'Sunday': 'Closed',
        },
        description: 'A warm and welcoming birth center focused on natural birthing options. We provide personalized care in a home-like setting with the safety of medical expertise nearby.',
        location: GeoPoint(latitude: -4.0435, longitude: 39.6682),
        workingHours: [],
        acceptedInsurance: [],
        createdAt: DateTime.now(),
        contactInfo: {
          'phone': '+254 41 567 8901',
          'email': 'contact@communitybirthcenter.co.ke',
          'website': 'www.communitybirthcenter.co.ke',
        }, updatedAt: DateTime.now(),
      ),
      HealthcareFacility(
        id: 'facility-3',
        name: 'Women\'s Wellness Clinic',
        type: 'Clinic',
        address: '789 Cedar Lane',
        imageUrl: 'assets/images/default_facility.png',
        city: 'Kisumu',
        state: 'Kisumu County',
        zipCode: '40100',
        phoneNumber: '+254 57 234 5678',
        email: '',
        website: '',
        latitude: -0.1022,
        longitude: 34.7617,
        services: [
          'Prenatal Care',
          'Family Planning',
          'Gynecological Exams',
          'STI Testing',
          'Health Education',
        ],
        specialists: [
          'Dr. Rose Atieno - OB/GYN',
          'Florence Njenga - Nurse Practitioner',
        ],
        rating: 4.2,
        reviews: [],
        operatingHours: {
          'Monday': '8:30 AM - 4:30 PM',
          'Tuesday': '8:30 AM - 4:30 PM',
          'Wednesday': '8:30 AM - 4:30 PM',
          'Thursday': '8:30 AM - 4:30 PM',
          'Friday': '8:30 AM - 4:30 PM',
          'Saturday': 'Closed',
          'Sunday': 'Closed',
        },
        description: 'A community clinic providing women\'s health services.',
        location: GeoPoint(latitude: -0.1022, longitude: 34.7617),
        acceptedInsurance: [], 
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(), contactInfo: {}, workingHours: [],
      ),
      
    ];
  }
}
