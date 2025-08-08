class HealthcareFacility {
  final String id;
  final String name;
  final GeoPoint location;
  final String type;
  final List<String> services;
  final Map<String, dynamic> contactInfo;
  final double rating;
  final List<String> workingHours;
  final bool emergencyServices;
  final List<String> acceptedInsurance;
  final String? description;
  final List<String> photos;
  final String address;
  final double? distance;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<FacilityReview>? reviews;

  var imageUrl;

  var phoneNumber;

  var email;

  var website;

  var specialists;

  var operatingHours;

  double latitude;

  double longitude;

  var city;

  var state;

  var zipCode;

  HealthcareFacility({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.services,
    required this.contactInfo,
    this.rating = 0.0,
    required this.workingHours,
    this.emergencyServices = false,
    required this.acceptedInsurance,
    this.description,
    this.photos = const [],
    required this.address,
    this.distance,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.phoneNumber,
    this.email,
    this.website,
    this.specialists,
    this.operatingHours,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.city,
    this.state,
    this.zipCode,
    this.reviews,
  });
  HealthcareFacility copyWith({
    String? id,
    String? name,
    GeoPoint? location,
    String? type,
    List<String>? services,
    Map<String, dynamic>? contactInfo,
    double? rating,
    List<String>? workingHours,
    bool? emergencyServices,
    List<String>? acceptedInsurance,
    String? description,
    List<String>? photos,
    String? address,
    double? distance,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic imageUrl,
    String? city,
    String? zipCode,
    String? state,
    String? country,
    dynamic phoneNumber,
    dynamic email,
    dynamic website,
    double? latitude,
    double? longitude,
    dynamic specialists,
    List<FacilityReview>? reviews,
    dynamic operatingHours,
  }) {
    return HealthcareFacility(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      type: type ?? this.type,
      services: services ?? this.services,
      contactInfo: contactInfo ?? this.contactInfo,
      rating: rating ?? this.rating,
      workingHours: workingHours ?? this.workingHours,
      emergencyServices: emergencyServices ?? this.emergencyServices,
      acceptedInsurance: acceptedInsurance ?? this.acceptedInsurance,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      state: state ?? this.state,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      specialists: specialists ?? this.specialists,
      operatingHours: operatingHours ?? this.operatingHours,
      reviews: reviews ?? this.reviews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location.toJson(),
      'type': type,
      'services': services,
      'contactInfo': contactInfo,
      'rating': rating,
      'workingHours': workingHours,
      'emergencyServices': emergencyServices,
      'acceptedInsurance': acceptedInsurance,
      'description': description,
      'photos': photos,
      'address': address,
      'distance': distance,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'city': city,
      'zipCode': zipCode,
      'state': state,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'reviews': reviews?.map((review) => review.toJson()).toList(),
    };
  }

  factory HealthcareFacility.fromJson(Map<String, dynamic> json) {
    return HealthcareFacility(
      id: json['id'],
      name: json['name'],
      location: GeoPoint.fromJson(json['location']),
      type: json['type'],
      services: List<String>.from(json['services']),
      contactInfo: Map<String, dynamic>.from(json['contactInfo']),
      rating: json['rating']?.toDouble() ?? 0.0,
      workingHours: json['workingHours'] != null 
          ? List<String>.from(json['workingHours']) 
          : [],
      emergencyServices: json['emergencyServices'] ?? false,
      acceptedInsurance: json['acceptedInsurance'] != null 
          ? List<String>.from(json['acceptedInsurance']) 
          : [],
      description: json['description'],
      photos: json['photos'] != null 
          ? List<String>.from(json['photos']) 
          : [],
      address: json['address'] ?? '',
      distance: json['distance']?.toDouble(),
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      imageUrl: json['imageUrl'],
      city: json['city'],
      zipCode: json['zipCode'],
      state: json['state'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      website: json['website'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      reviews: json['reviews'] != null
          ? List<FacilityReview>.from(
              json['reviews'].map((x) => FacilityReview.fromJson(x)))
          : null,
    );
  }
  
  @override
  bool operator ==(Object other) {
    return other is HealthcareFacility && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoPoint &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

enum FacilityType {
  hospital,
  clinic,
  maternityHome,
  healthCenter,
  pharmacy,
  laboratory,
  radiologyCenter,
  specialistClinic,
  emergencyCenter,
}

enum ServiceType {
  // Prenatal Services
  prenatalCheckup,
  ultrasound,
  bloodTests,
  geneticCounseling,
  prenatalClasses,
  
  // Labor and Delivery
  delivery,
  cesareanSection,
  epidural,
  waterBirth,
  
  // Postpartum Services
  postpartumCheckup,
  breastfeedingSupport,
  newbornCare,
  immunizations,
  
  // Emergency Services
  emergency24h,
  ambulanceService,
  intensiveCare,
  
  // Specialist Services
  obstetrician,
  gynecologist,
  pediatrician,
  anesthesiologist,
  nutritionist,
  
  // Support Services
  pharmacy,
  laboratory,
  xray,
  ultrasoundImaging,
  physiotherapy,
}

class FacilityFilter {
  final List<FacilityType> types;
  final List<ServiceType> services;
  final double? maxDistance;
  final double? minRating;
  final bool? emergencyOnly;
  final List<String> acceptedInsurance;
  final bool? openNow;

  const FacilityFilter({
    this.types = const [],
    this.services = const [],
    this.maxDistance,
    this.minRating,
    this.emergencyOnly,
    this.acceptedInsurance = const [],
    this.openNow,
  });

  FacilityFilter copyWith({
    List<FacilityType>? types,
    List<ServiceType>? services,
    double? maxDistance,
    double? minRating,
    bool? emergencyOnly,
    List<String>? acceptedInsurance,
    bool? openNow,
  }) {
    return FacilityFilter(
      types: types ?? this.types,
      services: services ?? this.services,
      maxDistance: maxDistance ?? this.maxDistance,
      minRating: minRating ?? this.minRating,
      emergencyOnly: emergencyOnly ?? this.emergencyOnly,
      acceptedInsurance: acceptedInsurance ?? this.acceptedInsurance,
      openNow: openNow ?? this.openNow,
    );
  }
}

class FacilityReview {
  final String id;
  final String facilityId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime visitDate;
  final DateTime createdAt;
  final List<String> tags;
  final bool isVerified;

  FacilityReview({
    required this.id,
    required this.facilityId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.visitDate,
    required this.createdAt,
    this.tags = const [],
    this.isVerified = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facilityId': facilityId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'visitDate': visitDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'isVerified': isVerified,
    };
  }

  factory FacilityReview.fromJson(Map<String, dynamic> json) {
    return FacilityReview(
      id: json['id'],
      facilityId: json['facilityId'],
      userId: json['userId'],
      userName: json['userName'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      visitDate: DateTime.parse(json['visitDate']),
      createdAt: DateTime.parse(json['createdAt']),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      isVerified: json['isVerified'] ?? false,
    );
  }
}

class AppointmentSlot {
  final String id;
  final String facilityId;
  final String providerId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? appointmentType;
  final double? cost;

  AppointmentSlot({
    required this.id,
    required this.facilityId,
    required this.providerId,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.appointmentType,
    this.cost,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facilityId': facilityId,
      'providerId': providerId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
      'appointmentType': appointmentType,
      'cost': cost,
    };
  }

  factory AppointmentSlot.fromJson(Map<String, dynamic> json) {
    return AppointmentSlot(
      id: json['id'],
      facilityId: json['facilityId'],
      providerId: json['providerId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isAvailable: json['isAvailable'] ?? true,
      appointmentType: json['appointmentType'],
      cost: json['cost']?.toDouble(),
    );
  }
}

// Predefined facility data for different African regions
class SampleFacilities {
  static List<HealthcareFacility> getSampleFacilities() {
    return [
      HealthcareFacility(
        id: 'facility_001',
        name: 'Kenyatta National Hospital',
        location: const GeoPoint(latitude: -1.3018, longitude: 36.8081),
        type: 'Hospital',
        services: [
          'Prenatal Care',
          'Delivery Services',
          'Emergency Care',
          'NICU',
          'Laboratory',
          'Pharmacy'
        ],
        contactInfo: {
          'phone': '+254-20-2726300',
          'email': 'info@knh.or.ke',
          'website': 'www.knh.or.ke'
        },
        rating: 4.2,
        workingHours: [
          'Monday-Sunday: 24 hours',
        ],
        emergencyServices: true,
        acceptedInsurance: ['NHIF', 'AAR', 'CIC', 'Jubilee'],
        address: 'Hospital Rd, Upper Hill, Nairobi',
        description: 'Leading public hospital with comprehensive maternity services',
        photos: ['knh_main.jpg', 'knh_maternity.jpg'],
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      
      HealthcareFacility(
        id: 'facility_002',
        name: 'Aga Khan University Hospital',
        location: const GeoPoint(latitude: -1.2740, longitude: 36.8061),
        type: 'Private Hospital',
        services: [
          'Prenatal Care',
          'High-Risk Pregnancy',
          'Water Birth',
          'Cesarean Section',
          'Postpartum Care'
        ],
        contactInfo: {
          'phone': '+254-20-3740000',
          'email': 'info@aku.edu',
          'website': 'www.aku.edu'
        },
        rating: 4.8,
        workingHours: [
          'Monday-Sunday: 24 hours',
        ],
        emergencyServices: true,
        acceptedInsurance: ['AAR', 'CIC', 'Jubilee', 'Liberty', 'Madison'],
        address: '3rd Parklands Ave, Nairobi',
        description: 'Premium private hospital with state-of-the-art maternity facilities',
        photos: ['aku_main.jpg', 'aku_maternity.jpg'],
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      HealthcareFacility(
        id: 'facility_003',
        name: 'Mama Lucy Kibaki Hospital',
        location: const GeoPoint(latitude: -1.2528, longitude: 36.8944),
        type: 'Public Hospital',
        services: [
          'Prenatal Care',
          'Normal Delivery',
          'Emergency Care',
          'Family Planning',
          'Immunization'
        ],
        contactInfo: {
          'phone': '+254-20-8571555',
          'email': 'info@mamalucy.go.ke',
        },
        rating: 3.8,
        workingHours: [
          'Monday-Sunday: 24 hours',
        ],
        emergencyServices: true,
        acceptedInsurance: ['NHIF'],
        address: 'Embakasi, Nairobi',
        description: 'Public hospital serving Eastlands area with quality maternity care',
        photos: ['mama_lucy_main.jpg'],
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),

      HealthcareFacility(
        id: 'facility_004',
        name: 'Marie Stopes Clinic',
        location: const GeoPoint(latitude: -1.2921, longitude: 36.8219),
        type: 'Clinic',
        services: [
          'Prenatal Care',
          'Family Planning',
          'Safe Motherhood',
          'Ultrasound',
          'Laboratory'
        ],
        contactInfo: {
          'phone': '+254-20-2731380',
          'email': 'info@mariestopes.or.ke',
        },
        rating: 4.1,
        workingHours: [
          'Monday-Friday: 8:00 AM - 5:00 PM',
          'Saturday: 8:00 AM - 1:00 PM',
          'Sunday: Closed'
        ],
        emergencyServices: false,
        acceptedInsurance: ['NHIF', 'AAR', 'CIC'],
        address: 'Mfangano St, Nairobi CBD',
        description: 'Specialized reproductive health clinic',
        photos: ['marie_stopes.jpg'],
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),

      HealthcareFacility(
        id: 'facility_005',
        name: 'Jamaa Mission Hospital',
        location: const GeoPoint(latitude: -1.3056, longitude: 36.7083),
        type: 'Mission Hospital',
        services: [
          'Prenatal Care',
          'Delivery Services',
          'Pediatric Care',
          'Laboratory',
          'Pharmacy'
        ],
        contactInfo: {
          'phone': '+254-20-891234',
          'email': 'info@jamaa.co.ke',
        },
        rating: 4.0,
        workingHours: [
          'Monday-Sunday: 24 hours',
        ],
        emergencyServices: true,
        acceptedInsurance: ['NHIF', 'AAR'],
        address: 'Kibera, Nairobi',
        description: 'Community hospital serving low-income families',
        photos: ['jamaa_main.jpg'],
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
    ];
  }
}
