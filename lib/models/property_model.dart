import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyModel {
  final String id;
  final String propertyCode;
  final String title;
  final String type; // kiwanja, nyumba, gari
  final String description;
  final double price;
  final String location;
  final String region;
  final String district;
  final String? ward;
  final String? street;
  
  // Land / Kiwanja Specific
  final String? size; // e.g. "500 SQM" or "20x30 M"
  final String? plotNumber;
  final String? blockNumber;
  final String? landUse; // Residential, Commercial, Industrial, Mixed
  final String? surveyStatus; // Not Surveyed, Surveying, Surveyed
  final String? registrationStatus; // Unregistered, Processing, Registered

  // House / Nyumba Specific
  final int? bedrooms;
  final int? bathrooms;

  // Vehicle / Gari Specific
  final String? vehicleMake;
  final String? vehicleModel;
  final int? vehicleYear;
  final String? vehicleRegistration;
  final String? vehicleMileage;
  final String? vehicleCondition; // Excellent, Good, Used

  // Geolocation
  final double? latitude;
  final double? longitude;

  // Media
  final List<String> images;
  final List<String> documents;

  // Status & Assignment
  final String status; // available, reserved, sold, inactive, under_process, surveying
  final String branchId;
  final String? assignedAgentId;
  final String? assignedSurveyorId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  PropertyModel({
    required this.id,
    required this.propertyCode,
    required this.title,
    required this.type,
    required this.description,
    required this.price,
    required this.location,
    required this.region,
    required this.district,
    this.ward,
    this.street,
    this.size,
    this.plotNumber,
    this.blockNumber,
    this.landUse,
    this.surveyStatus,
    this.registrationStatus,
    this.bedrooms,
    this.bathrooms,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleYear,
    this.vehicleRegistration,
    this.vehicleMileage,
    this.vehicleCondition,
    this.latitude,
    this.longitude,
    required this.images,
    required this.documents,
    required this.status,
    required this.branchId,
    this.assignedAgentId,
    this.assignedSurveyorId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PropertyModel.fromMap(Map<String, dynamic> map, String id) {
    return PropertyModel(
      id: id,
      propertyCode: map['propertyCode'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? 'kiwanja',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      location: map['location'] ?? '',
      region: map['region'] ?? '',
      district: map['district'] ?? '',
      ward: map['ward'],
      street: map['street'],
      size: map['size'],
      plotNumber: map['plotNumber'],
      blockNumber: map['blockNumber'],
      landUse: map['landUse'],
      surveyStatus: map['surveyStatus'],
      registrationStatus: map['registrationStatus'],
      bedrooms: map['bedrooms'] as int?,
      bathrooms: map['bathrooms'] as int?,
      vehicleMake: map['vehicleMake'],
      vehicleModel: map['vehicleModel'],
      vehicleYear: map['vehicleYear'] as int?,
      vehicleRegistration: map['vehicleRegistration'],
      vehicleMileage: map['vehicleMileage'],
      vehicleCondition: map['vehicleCondition'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      images: List<String>.from(map['images'] ?? []),
      documents: List<String>.from(map['documents'] ?? []),
      status: map['status'] ?? 'available',
      branchId: map['branchId'] ?? '',
      assignedAgentId: map['assignedAgentId'],
      assignedSurveyorId: map['assignedSurveyorId'],
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyCode': propertyCode,
      'title': title,
      'type': type,
      'description': description,
      'price': price,
      'location': location,
      'region': region,
      'district': district,
      'ward': ward,
      'street': street,
      'size': size,
      'plotNumber': plotNumber,
      'blockNumber': blockNumber,
      'landUse': landUse,
      'surveyStatus': surveyStatus,
      'registrationStatus': registrationStatus,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'vehicleRegistration': vehicleRegistration,
      'vehicleMileage': vehicleMileage,
      'vehicleCondition': vehicleCondition,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'documents': documents,
      'status': status,
      'branchId': branchId,
      'assignedAgentId': assignedAgentId,
      'assignedSurveyorId': assignedSurveyorId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
