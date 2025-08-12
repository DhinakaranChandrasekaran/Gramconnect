import 'dart:convert';

class UserModel {
  final String id;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? district;
  final String? panchayat;
  final String? ward;
  final String? homeAddress;
  final String? aadhaarNumber;
  final String authType;
  final bool isActive;
  final bool profileCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  String get village => panchayat ?? '';

  UserModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.district,
    this.panchayat,
    this.ward,
    this.homeAddress,
    this.aadhaarNumber,
    required this.authType,
    this.isActive = true,
    required this.profileCompleted,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      district: json['district'],
      panchayat: json['panchayat'],
      ward: json['ward'],
      homeAddress: json['homeAddress'],
      aadhaarNumber: json['aadhaarNumber'],
      authType: json['authType'] ?? 'EMAIL',
      isActive: json['active'] ?? true,
      profileCompleted: json['profileCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  factory UserModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = Map<String, dynamic>.from(jsonDecode(jsonString));
    return UserModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'district': district,
      'panchayat': panchayat,
      'ward': ward,
      'homeAddress': homeAddress,
      'aadhaarNumber': aadhaarNumber,
      'authType': authType,
      'active': isActive,
      'profileCompleted': profileCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? district,
    String? panchayat,
    String? ward,
    String? homeAddress,
    String? aadhaarNumber,
    String? authType,
    bool? isActive,
    bool? profileCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      district: district ?? this.district,
      panchayat: panchayat ?? this.panchayat,
      ward: ward ?? this.ward,
      homeAddress: homeAddress ?? this.homeAddress,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      authType: authType ?? this.authType,
      isActive: isActive ?? this.isActive,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
