class Appointment {
  final String id;
  final String userId;
  final String providerId;
  final String providerName;
  final DateTime appointmentDate;
  final String type;
  final String location;
  final String notes;
  final List<String> preparations;
  final List<String> questionsToAsk;
  final bool isCompleted;
  final String? followUpInstructions;
  final AppointmentStatus status;
  final String? cancellationReason;
  final DateTime? reminderTime;
  final bool reminderSent;
  final Map<String, dynamic>? insurance;
  final double? estimatedCost;
  final String? providerPhone;
  final String? providerEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.providerName,
    required this.appointmentDate,
    required this.type,
    required this.location,
    this.notes = '',
    this.preparations = const [],
    this.questionsToAsk = const [],
    this.isCompleted = false,
    this.followUpInstructions,
    this.status = AppointmentStatus.scheduled,
    this.cancellationReason,
    this.reminderTime,
    this.reminderSent = false,
    this.insurance,
    this.estimatedCost,
    this.providerPhone,
    this.providerEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  Appointment copyWith({
    String? id,
    String? userId,
    String? providerId,
    String? providerName,
    DateTime? appointmentDate,
    String? type,
    String? location,
    String? notes,
    List<String>? preparations,
    List<String>? questionsToAsk,
    bool? isCompleted,
    String? followUpInstructions,
    AppointmentStatus? status,
    String? cancellationReason,
    DateTime? reminderTime,
    bool? reminderSent,
    Map<String, dynamic>? insurance,
    double? estimatedCost,
    String? providerPhone,
    String? providerEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      type: type ?? this.type,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      preparations: preparations ?? this.preparations,
      questionsToAsk: questionsToAsk ?? this.questionsToAsk,
      isCompleted: isCompleted ?? this.isCompleted,
      followUpInstructions: followUpInstructions ?? this.followUpInstructions,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderSent: reminderSent ?? this.reminderSent,
      insurance: insurance ?? this.insurance,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      providerPhone: providerPhone ?? this.providerPhone,
      providerEmail: providerEmail ?? this.providerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'providerId': providerId,
      'providerName': providerName,
      'appointmentDate': appointmentDate.toIso8601String(),
      'type': type,
      'location': location,
      'notes': notes,
      'preparations': preparations,
      'questionsToAsk': questionsToAsk,
      'isCompleted': isCompleted,
      'followUpInstructions': followUpInstructions,
      'status': status.name,
      'cancellationReason': cancellationReason,
      'reminderTime': reminderTime?.toIso8601String(),
      'reminderSent': reminderSent,
      'insurance': insurance,
      'estimatedCost': estimatedCost,
      'providerPhone': providerPhone,
      'providerEmail': providerEmail,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      userId: json['userId'],
      providerId: json['providerId'],
      providerName: json['providerName'],
      appointmentDate: DateTime.parse(json['appointmentDate']),
      type: json['type'],
      location: json['location'],
      notes: json['notes'] ?? '',
      preparations: List<String>.from(json['preparations'] ?? []),
      questionsToAsk: List<String>.from(json['questionsToAsk'] ?? []),
      isCompleted: json['isCompleted'] ?? false,
      followUpInstructions: json['followUpInstructions'],
      status: AppointmentStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      cancellationReason: json['cancellationReason'],
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'])
          : null,
      reminderSent: json['reminderSent'] ?? false,
      insurance: json['insurance'] != null
          ? Map<String, dynamic>.from(json['insurance'])
          : null,
      estimatedCost: json['estimatedCost']?.toDouble(),
      providerPhone: json['providerPhone'],
      providerEmail: json['providerEmail'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'Appointment(id: $id, type: $type, date: $appointmentDate, provider: $providerName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  reminded,
  inProgress,
  completed,
  cancelled,
  noShow,
  rescheduled,
}

enum AppointmentType {
  prenatalCheckup,
  ultrasound,
  bloodTest,
  specialistConsultation,
  emergencyVisit,
  vaccination,
  nutritionConsultation,
  laborAndDelivery,
  postpartumCheckup,
  breastfeedingSupport,
}

class ReminderNotification {
  final String id;
  final String userId;
  final String appointmentId;
  final String title;
  final String message;
  final DateTime scheduledTime;
  final ReminderType type;
  final bool isDelivered;
  final bool isRead;
  final Map<String, dynamic>? actionData;
  final DateTime createdAt;

  ReminderNotification({
    required this.id,
    required this.userId,
    required this.appointmentId,
    required this.title,
    required this.message,
    required this.scheduledTime,
    required this.type,
    this.isDelivered = false,
    this.isRead = false,
    this.actionData,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'appointmentId': appointmentId,
      'title': title,
      'message': message,
      'scheduledTime': scheduledTime.toIso8601String(),
      'type': type.name,
      'isDelivered': isDelivered,
      'isRead': isRead,
      'actionData': actionData,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReminderNotification.fromJson(Map<String, dynamic> json) {
    return ReminderNotification(
      id: json['id'],
      userId: json['userId'],
      appointmentId: json['appointmentId'],
      title: json['title'],
      message: json['message'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      type: ReminderType.values.firstWhere(
        (type) => type.name == json['type'],
      ),
      isDelivered: json['isDelivered'] ?? false,
      isRead: json['isRead'] ?? false,
      actionData: json['actionData'] != null
          ? Map<String, dynamic>.from(json['actionData'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum ReminderType {
  appointment24Hours,
  appointment2Hours,
  appointment30Minutes,
  preparation,
  medicationTime,
  exerciseTime,
  mealTime,
  symptomLogging,
  prenatalVitamin,
  waterIntake,
  customReminder,
}

class PreparationChecklist {
  final String appointmentType;
  final List<ChecklistItem> items;
  final String? specialInstructions;

  const PreparationChecklist({
    required this.appointmentType,
    required this.items,
    this.specialInstructions,
  });
}

class ChecklistItem {
  final String id;
  final String title;
  final String? description;
  final bool isRequired;
  final ChecklistCategory category;
  final bool isCompleted;
  final DateTime? completedAt;

  const ChecklistItem({
    required this.id,
    required this.title,
    this.description,
    this.isRequired = false,
    required this.category,
    this.isCompleted = false,
    this.completedAt,
  });

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isRequired,
    ChecklistCategory? category,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isRequired: isRequired ?? this.isRequired,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

enum ChecklistCategory {
  documents,
  preparation,
  questions,
  items,
  medication,
  fasting,
}

class AppointmentPreparations {
  static Map<String, PreparationChecklist> getPreparationChecklists() {
    return {
      'Prenatal Checkup': PreparationChecklist(
        appointmentType: 'Prenatal Checkup',
        items: [
          ChecklistItem(
            id: 'pc_1',
            title: 'Bring insurance card',
            description: 'Have your insurance information ready',
            isRequired: true,
            category: ChecklistCategory.documents,
          ),
          ChecklistItem(
            id: 'pc_2',
            title: 'List of current medications',
            description: 'Include vitamins and supplements',
            isRequired: true,
            category: ChecklistCategory.documents,
          ),
          ChecklistItem(
            id: 'pc_3',
            title: 'Prepare questions for doctor',
            description: 'Write down any concerns or questions',
            category: ChecklistCategory.questions,
          ),
          ChecklistItem(
            id: 'pc_4',
            title: 'Update symptom diary',
            description: 'Bring your recent symptom tracking',
            category: ChecklistCategory.preparation,
          ),
        ],
      ),
      'Ultrasound': PreparationChecklist(
        appointmentType: 'Ultrasound',
        items: [
          ChecklistItem(
            id: 'us_1',
            title: 'Drink 32oz of water 1 hour before',
            description: 'Full bladder helps with imaging',
            isRequired: true,
            category: ChecklistCategory.preparation,
          ),
          ChecklistItem(
            id: 'us_2',
            title: 'Wear comfortable clothing',
            description: 'Two-piece outfit for easy access to belly',
            category: ChecklistCategory.preparation,
          ),
          ChecklistItem(
            id: 'us_3',
            title: 'Bring partner or support person',
            description: 'Share this special moment',
            category: ChecklistCategory.preparation,
          ),
        ],
        specialInstructions: 'Arrive 15 minutes early for check-in',
      ),
      'Blood Test': PreparationChecklist(
        appointmentType: 'Blood Test',
        items: [
          ChecklistItem(
            id: 'bt_1',
            title: 'Fast for 8-12 hours if required',
            description: 'Check with your doctor about fasting requirements',
            isRequired: true,
            category: ChecklistCategory.fasting,
          ),
          ChecklistItem(
            id: 'bt_2',
            title: 'Stay hydrated',
            description: 'Drink plenty of water (unless fasting)',
            category: ChecklistCategory.preparation,
          ),
          ChecklistItem(
            id: 'bt_3',
            title: 'Wear short sleeves',
            description: 'Makes blood draw easier',
            category: ChecklistCategory.preparation,
          ),
        ],
      ),
      'Labor and Delivery': PreparationChecklist(
        appointmentType: 'Labor and Delivery',
        items: [
          ChecklistItem(
            id: 'ld_1',
            title: 'Hospital bag packed',
            description: 'Baby clothes, personal items, documents',
            isRequired: true,
            category: ChecklistCategory.items,
          ),
          ChecklistItem(
            id: 'ld_2',
            title: 'Birth plan ready',
            description: 'Your preferences for labor and delivery',
            category: ChecklistCategory.documents,
          ),
          ChecklistItem(
            id: 'ld_3',
            title: 'Emergency contacts list',
            description: 'Family and friends to notify',
            isRequired: true,
            category: ChecklistCategory.documents,
          ),
          ChecklistItem(
            id: 'ld_4',
            title: 'Car seat installed',
            description: 'Required before leaving hospital',
            isRequired: true,
            category: ChecklistCategory.preparation,
          ),
        ],
        specialInstructions: 'Call hospital when contractions are 5 minutes apart for 1 hour',
      ),
    };
  }

  static List<String> getCommonQuestions(String appointmentType) {
    final questionsMap = {
      'Prenatal Checkup': [
        'Is my baby developing normally?',
        'What symptoms should I watch out for?',
        'Are my prenatal vitamins adequate?',
        'How much weight should I gain?',
        'What exercises are safe for me?',
        'When will I feel the baby move?',
        'What foods should I avoid?',
        'How often should I have checkups?',
      ],
      'Ultrasound': [
        'Is the baby the right size for my due date?',
        'Can you tell the baby\'s gender?',
        'Is the placenta positioned correctly?',
        'How much amniotic fluid is there?',
        'Can I get printed pictures?',
        'Is everything developing normally?',
        'When is my next ultrasound?',
      ],
      'Blood Test': [
        'What are you testing for?',
        'When will I get the results?',
        'What do abnormal results mean?',
        'Do I need to fast for any other tests?',
        'Are there any risks to the baby?',
        'How often will I need blood tests?',
      ],
      'Labor and Delivery': [
        'What are the signs of labor?',
        'When should I come to the hospital?',
        'What pain relief options are available?',
        'What if I need a C-section?',
        'Can my partner stay with me?',
        'What happens immediately after birth?',
        'How long will I stay in the hospital?',
      ],
    };

    return questionsMap[appointmentType] ?? [];
  }
}
