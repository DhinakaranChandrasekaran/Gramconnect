class GarbageScheduleModel {
  final String id;
  final String district;  // match backend field name
  final String panchayat; // if applicable, else use village
  final String? ward;
  final String? area;
  final List<String> collectionDays;
  final String pickupTime; // stored as "HH:mm:ss"
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GarbageScheduleModel({
    required this.id,
    required this.district,
    required this.panchayat,
    this.ward,
    this.area,
    required this.collectionDays,
    required this.pickupTime,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory GarbageScheduleModel.fromJson(Map<String, dynamic> json) {
    return GarbageScheduleModel(
      id: json['_id'] ?? json['id'] ?? '',
      district: json['district'] ?? '',
      panchayat: json['panchayat'] ?? '',
      ward: json['ward'],
      area: json['area'],
      collectionDays: List<String>.from(json['collectionDays'] ?? []),
      pickupTime: json['pickupTime'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'district': district,
      'panchayat': panchayat,
      'ward': ward,
      'area': area,
      'collectionDays': collectionDays,
      'pickupTime': pickupTime,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Compose display area text (fallback)
  String get displayArea => area ?? '$panchayat${ward != null ? ', Ward $ward' : ''}';

  // Calculate next collection day as "Today", "Tomorrow", or "in X days"
  String get nextCollectionDay {
    final now = DateTime.now();
    final currentDay = _getDayName(now.weekday);

    for (int i = 0; i < 7; i++) {
      final checkDay = _getDayName((now.weekday + i - 1) % 7 + 1);
      if (collectionDays.contains(checkDay)) {
        if (i == 0) return 'Today';
        if (i == 1) return 'Tomorrow';
        return 'in $i days';
      }
    }
    return 'Not scheduled';
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
}