class ComplaintModel {
  final String id;
  final String complaintId;
  final String userId;
  final String category;
  final String description;
  final String? imageUrl;
  final LocationData location;
  final String village;
  final String? ward;
  final String status;
  final bool reminderSent;
  final String? feedback;
  final int? rating;
  final String? adminResponse;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  ComplaintModel({
    required this.id,
    required this.complaintId,
    required this.userId,
    required this.category,
    required this.description,
    this.imageUrl,
    required this.location,
    required this.village,
    this.ward,
    this.status = 'PENDING',
    this.reminderSent = false,
    this.feedback,
    this.rating,
    this.adminResponse,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] ?? '',
      complaintId: json['complaintId'] ?? '',
      userId: json['userId'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      location: LocationData.fromJson(json['location'] ?? {}),
      village: json['village'] ?? '',
      ward: json['ward'],
      status: json['status'] ?? 'PENDING',
      reminderSent: json['reminderSent'] ?? false,
      feedback: json['feedback'],
      rating: json['rating'],
      adminResponse: json['adminResponse'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaintId': complaintId,
      'userId': userId,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'location': location.toJson(),
      'village': village,
      'ward': ward,
      'status': status,
      'reminderSent': reminderSent,
      'feedback': feedback,
      'rating': rating,
      'adminResponse': adminResponse,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  ComplaintModel copyWith({
    String? id,
    String? complaintId,
    String? userId,
    String? category,
    String? description,
    String? imageUrl,
    LocationData? location,
    String? village,
    String? ward,
    String? status,
    bool? reminderSent,
    String? feedback,
    int? rating,
    String? adminResponse,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      complaintId: complaintId ?? this.complaintId,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      village: village ?? this.village,
      ward: ward ?? this.ward,
      status: status ?? this.status,
      reminderSent: reminderSent ?? this.reminderSent,
      feedback: feedback ?? this.feedback,
      rating: rating ?? this.rating,
      adminResponse: adminResponse ?? this.adminResponse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'RESOLVED':
        return 'Resolved';
      case 'REJECTED':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  String get categoryDisplayName {
    switch (category) {
      case 'GARBAGE':
        return 'Garbage';
      case 'WATER_SUPPLY':
        return 'Water Supply';
      case 'ELECTRICITY':
        return 'Electricity';
      case 'DRAINAGE':
        return 'Drainage';
      case 'ROAD_DAMAGE':
        return 'Road Damage';
      case 'HEALTH_CENTER':
        return 'Health Center';
      case 'TRANSPORT':
        return 'Transport';
      default:
        return 'Other';
    }
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}