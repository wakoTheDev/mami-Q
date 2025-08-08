class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final String? medicalInfo;
  final bool isPrimary;
  final String? email;
  final String? address;
  final bool isEmergencyService;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.medicalInfo,
    this.isPrimary = false,
    this.email,
    this.address,
    this.isEmergencyService = false,
    this.priority = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    String? medicalInfo,
    bool? isPrimary,
    String? email,
    String? address,
    bool? isEmergencyService,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      isPrimary: isPrimary ?? this.isPrimary,
      email: email ?? this.email,
      address: address ?? this.address,
      isEmergencyService: isEmergencyService ?? this.isEmergencyService,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'medicalInfo': medicalInfo,
      'isPrimary': isPrimary,
      'email': email,
      'address': address,
      'isEmergencyService': isEmergencyService,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      relationship: json['relationship'],
      medicalInfo: json['medicalInfo'],
      isPrimary: json['isPrimary'] ?? false,
      email: json['email'],
      address: json['address'],
      isEmergencyService: json['isEmergencyService'] ?? false,
      priority: json['priority'] ?? 1,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'EmergencyContact(name: $name, relationship: $relationship, phone: $phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyContact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class EmergencyAlert {
  final String id;
  final String userId;
  final DateTime timestamp;
  final GeoPoint? location;
  final String alertType;
  final String message;
  final List<String> contactedPersons;
  final bool isResolved;
  final String? resolution;
  final EmergencyLevel level;
  final Map<String, dynamic>? additionalData;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  EmergencyAlert({
    required this.id,
    required this.userId,
    required this.timestamp,
    this.location,
    required this.alertType,
    required this.message,
    this.contactedPersons = const [],
    this.isResolved = false,
    this.resolution,
    required this.level,
    this.additionalData,
    this.resolvedAt,
    this.resolvedBy,
  });

  EmergencyAlert copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    GeoPoint? location,
    String? alertType,
    String? message,
    List<String>? contactedPersons,
    bool? isResolved,
    String? resolution,
    EmergencyLevel? level,
    Map<String, dynamic>? additionalData,
    DateTime? resolvedAt,
    String? resolvedBy,
  }) {
    return EmergencyAlert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      alertType: alertType ?? this.alertType,
      message: message ?? this.message,
      contactedPersons: contactedPersons ?? this.contactedPersons,
      isResolved: isResolved ?? this.isResolved,
      resolution: resolution ?? this.resolution,
      level: level ?? this.level,
      additionalData: additionalData ?? this.additionalData,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'location': location?.toJson(),
      'alertType': alertType,
      'message': message,
      'contactedPersons': contactedPersons,
      'isResolved': isResolved,
      'resolution': resolution,
      'level': level.name,
      'additionalData': additionalData,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
    };
  }

  factory EmergencyAlert.fromJson(Map<String, dynamic> json) {
    return EmergencyAlert(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'] != null 
          ? GeoPoint.fromJson(json['location'])
          : null,
      alertType: json['alertType'],
      message: json['message'],
      contactedPersons: List<String>.from(json['contactedPersons'] ?? []),
      isResolved: json['isResolved'] ?? false,
      resolution: json['resolution'],
      level: EmergencyLevel.values.firstWhere(
        (level) => level.name == json['level'],
        orElse: () => EmergencyLevel.medium,
      ),
      additionalData: json['additionalData'] != null
          ? Map<String, dynamic>.from(json['additionalData'])
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      resolvedBy: json['resolvedBy'],
    );
  }
}

class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }

  @override
  String toString() {
    return 'GeoPoint(lat: $latitude, lng: $longitude)';
  }
}

enum EmergencyLevel {
  low,
  medium,
  high,
  critical,
}

enum EmergencyType {
  medicalEmergency,
  laborPains,
  severeSymptoms,
  accidentInjury,
  mentalHealthCrisis,
  domesticViolence,
  other,
}

class MedicalInformation {
  final String userId;
  final String? bloodType;
  final List<String> allergies;
  final List<String> medications;
  final List<String> medicalConditions;
  final String? emergencyMedicalInfo;
  final DateTime? lastUpdated;
  final String? preferredHospital;
  final String? doctorName;
  final String? doctorPhone;
  final int? pregnancyWeek;
  final DateTime? dueDate;
  final bool isHighRiskPregnancy;
  final List<String> pregnancyComplications;

  MedicalInformation({
    required this.userId,
    this.bloodType,
    this.allergies = const [],
    this.medications = const [],
    this.medicalConditions = const [],
    this.emergencyMedicalInfo,
    this.lastUpdated,
    this.preferredHospital,
    this.doctorName,
    this.doctorPhone,
    this.pregnancyWeek,
    this.dueDate,
    this.isHighRiskPregnancy = false,
    this.pregnancyComplications = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'bloodType': bloodType,
      'allergies': allergies,
      'medications': medications,
      'medicalConditions': medicalConditions,
      'emergencyMedicalInfo': emergencyMedicalInfo,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'preferredHospital': preferredHospital,
      'doctorName': doctorName,
      'doctorPhone': doctorPhone,
      'pregnancyWeek': pregnancyWeek,
      'dueDate': dueDate?.toIso8601String(),
      'isHighRiskPregnancy': isHighRiskPregnancy,
      'pregnancyComplications': pregnancyComplications,
    };
  }

  factory MedicalInformation.fromJson(Map<String, dynamic> json) {
    return MedicalInformation(
      userId: json['userId'],
      bloodType: json['bloodType'],
      allergies: List<String>.from(json['allergies'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      medicalConditions: List<String>.from(json['medicalConditions'] ?? []),
      emergencyMedicalInfo: json['emergencyMedicalInfo'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      preferredHospital: json['preferredHospital'],
      doctorName: json['doctorName'],
      doctorPhone: json['doctorPhone'],
      pregnancyWeek: json['pregnancyWeek'],
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
      isHighRiskPregnancy: json['isHighRiskPregnancy'] ?? false,
      pregnancyComplications: List<String>.from(json['pregnancyComplications'] ?? []),
    );
  }
}

class EmergencyProtocol {
  static Map<EmergencyType, EmergencyProtocolAction> getProtocols() {
    return {
      EmergencyType.medicalEmergency: EmergencyProtocolAction(
        title: 'Medical Emergency',
        immediateActions: [
          'Call 911 or local emergency number',
          'Stay calm and don\'t move if injured',
          'If conscious, stay on the line with emergency services',
          'Have someone contact your emergency contacts',
        ],
        informationToProvide: [
          'Your exact location',
          'Nature of the emergency',
          'Your pregnancy status and week',
          'Any allergies or medical conditions',
          'Current medications',
        ],
        contactOrder: [
          'Emergency Services (911)',
          'Primary Emergency Contact',
          'Healthcare Provider',
          'Secondary Emergency Contacts',
        ],
      ),
      
      EmergencyType.laborPains: EmergencyProtocolAction(
        title: 'Labor Pains',
        immediateActions: [
          'Time your contractions',
          'Call your healthcare provider',
          'If contractions are 5 minutes apart for 1 hour, go to hospital',
          'Stay hydrated and rest between contractions',
        ],
        informationToProvide: [
          'How far apart contractions are',
          'How long each contraction lasts',
          'Your pregnancy week',
          'If your water has broken',
          'Any unusual symptoms',
        ],
        contactOrder: [
          'Healthcare Provider',
          'Hospital Labor & Delivery',
          'Primary Emergency Contact',
          'Transportation Arrangement',
        ],
      ),
      
      EmergencyType.severeSymptoms: EmergencyProtocolAction(
        title: 'Severe Pregnancy Symptoms',
        immediateActions: [
          'Document your symptoms',
          'Call your healthcare provider immediately',
          'If severe, call 911',
          'Do not drive yourself',
        ],
        informationToProvide: [
          'Specific symptoms you\'re experiencing',
          'When symptoms started',
          'Severity level (1-10)',
          'Your pregnancy week',
          'Any triggers you noticed',
        ],
        contactOrder: [
          'Healthcare Provider',
          'Emergency Services (if severe)',
          'Primary Emergency Contact',
          'Preferred Hospital',
        ],
      ),
    };
  }
}

class EmergencyProtocolAction {
  final String title;
  final List<String> immediateActions;
  final List<String> informationToProvide;
  final List<String> contactOrder;

  const EmergencyProtocolAction({
    required this.title,
    required this.immediateActions,
    required this.informationToProvide,
    required this.contactOrder,
  });
}

class EmergencyChecklist {
  static List<String> getPreEmergencyChecklist() {
    return [
      'Keep emergency contacts updated',
      'Ensure medical information is current',
      'Have hospital bag ready (after 32 weeks)',
      'Know the route to your preferred hospital',
      'Keep phone charged and accessible',
      'Have backup transportation arranged',
      'Inform family of emergency protocols',
      'Keep insurance cards easily accessible',
    ];
  }

  static List<String> getWarningSignsToWatch() {
    return [
      'Severe headache that won\'t go away',
      'Vision changes or blurred vision',
      'Severe swelling of face or hands',
      'Persistent severe abdominal pain',
      'Heavy bleeding',
      'Persistent vomiting',
      'High fever (over 101°F)',
      'Severe back pain',
      'Contractions before 37 weeks',
      'Baby\'s movement decreases significantly',
      'Fluid leaking from vagina',
      'Difficulty breathing',
      'Chest pain',
      'Severe dizziness or fainting',
    ];
  }

  static Map<String, String> getEmergencyNumbers() {
    return {
      'Emergency Services': '911',
      'Poison Control': '1-800-222-1222',
      'Suicide Prevention': '988',
      'Domestic Violence': '1-800-799-7233',
      'Mental Health Crisis': '1-800-273-8255',
    };
  }
}
