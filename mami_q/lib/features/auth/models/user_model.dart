import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final DateTime expectedDueDate;
  final DateTime pregnancyStartDate;
  final int currentWeek;
  final int trimester;
  final String? phoneNumber;
  final DateTime dateOfBirth;
  final double? height;
  final double? prePregnancyWeight;
  final String? bloodType;
  final List<String> allergies;
  final List<String> medicalConditions;
  final List<String> medications;
  final String? doctorName;
  final String? doctorPhone;
  final String? hospitalName;
  final String? insuranceProvider;
  final String? emergencyContact;
  final String? emergencyContactPhone;
  final Map<String, dynamic> preferences;
  final int totalTokens;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final bool notificationsEnabled;
  final bool locationEnabled;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.expectedDueDate,
    required this.pregnancyStartDate,
    required this.currentWeek,
    required this.trimester,
    this.phoneNumber,
    required this.dateOfBirth,
    this.height,
    this.prePregnancyWeight,
    this.bloodType,
    this.allergies = const [],
    this.medicalConditions = const [],
    this.medications = const [],
    this.doctorName,
    this.doctorPhone,
    this.hospitalName,
    this.insuranceProvider,
    this.emergencyContact,
    this.emergencyContactPhone,
    this.preferences = const {},
    this.totalTokens = 0,
    required this.createdAt,
    required this.lastActiveAt,
    this.notificationsEnabled = true,
    this.locationEnabled = false,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    DateTime? expectedDueDate,
    DateTime? pregnancyStartDate,
    int? currentWeek,
    int? trimester,
    String? phoneNumber,
    DateTime? dateOfBirth,
    double? height,
    double? prePregnancyWeight,
    String? bloodType,
    List<String>? allergies,
    List<String>? medicalConditions,
    List<String>? medications,
    String? doctorName,
    String? doctorPhone,
    String? hospitalName,
    String? insuranceProvider,
    String? emergencyContact,
    String? emergencyContactPhone,
    Map<String, dynamic>? preferences,
    int? totalTokens,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? notificationsEnabled,
    bool? locationEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      expectedDueDate: expectedDueDate ?? this.expectedDueDate,
      pregnancyStartDate: pregnancyStartDate ?? this.pregnancyStartDate,
      currentWeek: currentWeek ?? this.currentWeek,
      trimester: trimester ?? this.trimester,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      prePregnancyWeight: prePregnancyWeight ?? this.prePregnancyWeight,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medications: medications ?? this.medications,
      doctorName: doctorName ?? this.doctorName,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      hospitalName: hospitalName ?? this.hospitalName,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      preferences: preferences ?? this.preferences,
      totalTokens: totalTokens ?? this.totalTokens,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locationEnabled: locationEnabled ?? this.locationEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'expectedDueDate': Timestamp.fromDate(expectedDueDate),
      'pregnancyStartDate': Timestamp.fromDate(pregnancyStartDate),
      'currentWeek': currentWeek,
      'trimester': trimester,
      'phoneNumber': phoneNumber,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'height': height,
      'prePregnancyWeight': prePregnancyWeight,
      'bloodType': bloodType,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'medications': medications,
      'doctorName': doctorName,
      'doctorPhone': doctorPhone,
      'hospitalName': hospitalName,
      'insuranceProvider': insuranceProvider,
      'emergencyContact': emergencyContact,
      'emergencyContactPhone': emergencyContactPhone,
      'preferences': preferences,
      'totalTokens': totalTokens,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'notificationsEnabled': notificationsEnabled,
      'locationEnabled': locationEnabled,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      expectedDueDate: (map['expectedDueDate'] as Timestamp).toDate(),
      pregnancyStartDate: (map['pregnancyStartDate'] as Timestamp).toDate(),
      currentWeek: map['currentWeek']?.toInt() ?? 0,
      trimester: map['trimester']?.toInt() ?? 1,
      phoneNumber: map['phoneNumber'],
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      height: map['height']?.toDouble(),
      prePregnancyWeight: map['prePregnancyWeight']?.toDouble(),
      bloodType: map['bloodType'],
      allergies: List<String>.from(map['allergies'] ?? []),
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
      medications: List<String>.from(map['medications'] ?? []),
      doctorName: map['doctorName'],
      doctorPhone: map['doctorPhone'],
      hospitalName: map['hospitalName'],
      insuranceProvider: map['insuranceProvider'],
      emergencyContact: map['emergencyContact'],
      emergencyContactPhone: map['emergencyContactPhone'],
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      totalTokens: map['totalTokens']?.toInt() ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastActiveAt: (map['lastActiveAt'] as Timestamp).toDate(),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      locationEnabled: map['locationEnabled'] ?? false,
    );
  }

  // Helper methods
  int get daysPregnant {
    return DateTime.now().difference(pregnancyStartDate).inDays;
  }

  int get daysUntilDue {
    return expectedDueDate.difference(DateTime.now()).inDays;
  }

  double get pregnancyProgress {
    return currentWeek / 40.0;
  }

  String get trimesterName {
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

  bool get isHighRiskPregnancy {
    return medicalConditions.isNotEmpty || 
           (dateOfBirth.isBefore(DateTime.now().subtract(const Duration(days: 365 * 35)))) ||
           (dateOfBirth.isAfter(DateTime.now().subtract(const Duration(days: 365 * 18))));
  }

  String get bmi {
    if (height != null && prePregnancyWeight != null) {
      final heightInMeters = height! / 100;
      final bmiValue = prePregnancyWeight! / (heightInMeters * heightInMeters);
      return bmiValue.toStringAsFixed(1);
    }
    return 'N/A';
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, currentWeek: $currentWeek)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.currentWeek == currentWeek;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        currentWeek.hashCode;
  }
}
