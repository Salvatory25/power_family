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
  final String? documentation; // Title Deed, Offer Letter, Other

  // House / Nyumba Specific
  final String? houseType; // House, Villa, Apartment
  final String? houseCondition; // New, Used
  final int? bedrooms;
  final int? bathrooms;

  // Vehicle / Gari Specific
  final String? vehicleMake;
  final String? vehicleModel;
  final int? vehicleYear;
  final String? vehicleRegistration;
  final String? vehicleMileage;
  final String? vehicleCondition; // Excellent, Good, Used
  final String? fuelType; // Petrol, Diesel, Hybrid, Electric
  final String? transmission; // Automatic, Manual
  final String? bodyType; // SUV, Sedan, Hatchback, Pickup, Van, Wagon, Other
  final String? color;

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
  // Acquisition & Payments
  final List<String> allowedAcquisitionPlans; // 'FULL_PAYMENT', 'INSTALLMENT', 'KIKOBA'
  final List<Map<String, dynamic>> installmentPlans;
  final List<String> eligibleKikobaPackages;

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
    this.documentation,
    this.houseType,
    this.houseCondition,
    this.bedrooms,
    this.bathrooms,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleYear,
    this.vehicleRegistration,
    this.vehicleMileage,
    this.vehicleCondition,
    this.fuelType,
    this.transmission,
    this.bodyType,
    this.color,
    this.latitude,
    this.longitude,
    this.images = const [],
    this.documents = const [],
    this.allowedAcquisitionPlans = const ['FULL_PAYMENT'],
    this.installmentPlans = const [],
    this.eligibleKikobaPackages = const [],
    this.status = 'AVAILABLE',
    this.branchId = 'branch_dar',
    this.assignedAgentId,
    this.assignedSurveyorId,
    this.createdBy = 'system',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

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
      documentation: map['documentation'],
      houseType: map['houseType'],
      houseCondition: map['houseCondition'],
      bedrooms: map['bedrooms'] as int?,
      bathrooms: map['bathrooms'] as int?,
      vehicleMake: map['vehicleMake'],
      vehicleModel: map['vehicleModel'],
      vehicleYear: map['vehicleYear'] as int?,
      vehicleRegistration: map['vehicleRegistration'],
      vehicleMileage: map['vehicleMileage'],
      vehicleCondition: map['vehicleCondition'],
      fuelType: map['fuelType'],
      transmission: map['transmission'],
      bodyType: map['bodyType'],
      color: map['color'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      images: List<String>.from(map['images'] ?? []),
      documents: List<String>.from(map['documents'] ?? []),
      allowedAcquisitionPlans: List<String>.from(map['allowedAcquisitionPlans'] ?? ['FULL_PAYMENT']),
      installmentPlans: List<Map<String, dynamic>>.from(map['installmentPlans'] ?? []),
      eligibleKikobaPackages: List<String>.from(map['eligibleKikobaPackages'] ?? []),
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
      'documentation': documentation,
      'houseType': houseType,
      'houseCondition': houseCondition,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'vehicleRegistration': vehicleRegistration,
      'vehicleMileage': vehicleMileage,
      'vehicleCondition': vehicleCondition,
      'fuelType': fuelType,
      'transmission': transmission,
      'bodyType': bodyType,
      'color': color,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'documents': documents,
      'allowedAcquisitionPlans': allowedAcquisitionPlans,
      'installmentPlans': installmentPlans,
      'eligibleKikobaPackages': eligibleKikobaPackages,
      'status': status,
      'branchId': branchId,
      'assignedAgentId': assignedAgentId,
      'assignedSurveyorId': assignedSurveyorId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  PropertyModel copyWith({
    String? propertyCode,
    String? title,
    String? type,
    String? description,
    double? price,
    String? location,
    String? region,
    String? district,
    String? ward,
    String? street,
    String? size,
    String? plotNumber,
    String? blockNumber,
    String? landUse,
    String? surveyStatus,
    String? registrationStatus,
    String? documentation,
    String? houseType,
    String? houseCondition,
    int? bedrooms,
    int? bathrooms,
    String? vehicleMake,
    String? vehicleModel,
    int? vehicleYear,
    String? vehicleRegistration,
    String? vehicleMileage,
    String? vehicleCondition,
    String? fuelType,
    String? transmission,
    String? bodyType,
    String? color,
    double? latitude,
    double? longitude,
    List<String>? images,
    List<String>? documents,
    List<String>? allowedAcquisitionPlans,
    List<Map<String, dynamic>>? installmentPlans,
    List<String>? eligibleKikobaPackages,
    String? status,
    String? branchId,
    String? assignedAgentId,
    String? assignedSurveyorId,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return PropertyModel(
      id: id,
      propertyCode: propertyCode ?? this.propertyCode,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      region: region ?? this.region,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      street: street ?? this.street,
      size: size ?? this.size,
      plotNumber: plotNumber ?? this.plotNumber,
      blockNumber: blockNumber ?? this.blockNumber,
      landUse: landUse ?? this.landUse,
      surveyStatus: surveyStatus ?? this.surveyStatus,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      documentation: documentation ?? this.documentation,
      houseType: houseType ?? this.houseType,
      houseCondition: houseCondition ?? this.houseCondition,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      vehicleMileage: vehicleMileage ?? this.vehicleMileage,
      vehicleCondition: vehicleCondition ?? this.vehicleCondition,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      bodyType: bodyType ?? this.bodyType,
      color: color ?? this.color,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      documents: documents ?? this.documents,
      allowedAcquisitionPlans: allowedAcquisitionPlans ?? this.allowedAcquisitionPlans,
      installmentPlans: installmentPlans ?? this.installmentPlans,
      eligibleKikobaPackages: eligibleKikobaPackages ?? this.eligibleKikobaPackages,
      status: status ?? this.status,
      branchId: branchId ?? this.branchId,
      assignedAgentId: assignedAgentId ?? this.assignedAgentId,
      assignedSurveyorId: assignedSurveyorId ?? this.assignedSurveyorId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
