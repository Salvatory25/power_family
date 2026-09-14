import 'package:flutter/foundation.dart';

@immutable
class PlotModel {
  final String id;
  final String plotId; // e.g. PFI-KIB-000001
  final String plotNumber;
  final String blockName;
  final String projectId;
  final String branchId;
  final String region;
  final String district;
  final String? ward;
  final String? villageStreet;
  final String? locationDescription;
  
  final double? gpsLatitude;
  final double? gpsLongitude;
  final List<Map<String, double>> boundaryCoordinates; // Polygon points
  final double areaSqm;
  final double? perimeterMeters;
  final String landUse;
  final String plotType;
  
  final double listPrice;
  final double discountAmount;
  final double sellingPrice;
  final double requiredDeposit;
  final int installmentTermsMonths;
  
  final String availabilityStatus; // AVAILABLE, RESERVED, BOOKED, SOLD, INSTALLMENT, FULLY_PAID, etc.
  final String surveyStatus;
  final String bitconStatus;
  final String halmashauriStatus;
  final String titleStatus;
  
  final String? currentCustomerId;
  final String? currentBookingId;
  final String? currentSaleId;
  final String? assignedSalesAgentId;
  
  final List<String> documents;
  final Map<String, dynamic> surveyData;
  final List<String> photos;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlotModel({
    required this.id,
    required this.plotId,
    required this.plotNumber,
    required this.blockName,
    required this.projectId,
    required this.branchId,
    required this.region,
    required this.district,
    this.ward,
    this.villageStreet,
    this.locationDescription,
    this.gpsLatitude,
    this.gpsLongitude,
    this.boundaryCoordinates = const [],
    required this.areaSqm,
    this.perimeterMeters,
    this.landUse = 'RESIDENTIAL',
    this.plotType = 'STANDARD',
    required this.listPrice,
    this.discountAmount = 0.0,
    required this.sellingPrice,
    this.requiredDeposit = 0.0,
    this.installmentTermsMonths = 12,
    this.availabilityStatus = 'AVAILABLE',
    this.surveyStatus = 'NOT_STARTED',
    this.bitconStatus = 'NOT_STARTED',
    this.halmashauriStatus = 'NOT_STARTED',
    this.titleStatus = 'NOT_STARTED',
    this.currentCustomerId,
    this.currentBookingId,
    this.currentSaleId,
    this.assignedSalesAgentId,
    this.documents = const [],
    this.surveyData = const {},
    this.photos = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlotModel.fromMap(Map<String, dynamic> map, String docId) {
    List<Map<String, double>> coords = [];
    if (map['boundaryCoordinates'] != null && map['boundaryCoordinates'] is List) {
      for (var item in (map['boundaryCoordinates'] as List)) {
        if (item is Map) {
          coords.add({
            'lat': (item['lat'] as num).toDouble(),
            'lng': (item['lng'] as num).toDouble(),
          });
        }
      }
    }

    final double listP = (map['listPrice'] as num?)?.toDouble() ?? 0.0;
    final double disc = (map['discountAmount'] as num?)?.toDouble() ?? 0.0;
    final double sellP = (map['sellingPrice'] as num?)?.toDouble() ?? (listP - disc);

    return PlotModel(
      id: docId,
      plotId: map['plotId'] ?? map['plot_id'] ?? docId,
      plotNumber: map['plotNumber'] ?? map['plot_number'] ?? '',
      blockName: map['blockName'] ?? map['block_name'] ?? 'Block A',
      projectId: map['projectId'] ?? map['project_id'] ?? '',
      branchId: map['branchId'] ?? map['branch_id'] ?? '',
      region: map['region'] ?? 'Pwani',
      district: map['district'] ?? 'Kibaha',
      ward: map['ward'],
      villageStreet: map['villageStreet'] ?? map['village_street'],
      locationDescription: map['locationDescription'] ?? map['location_description'],
      gpsLatitude: (map['gpsLatitude'] ?? map['gps_latitude'] as num?)?.toDouble(),
      gpsLongitude: (map['gpsLongitude'] ?? map['gps_longitude'] as num?)?.toDouble(),
      boundaryCoordinates: coords,
      areaSqm: (map['areaSqm'] ?? map['area_sqm'] as num?)?.toDouble() ?? 0.0,
      perimeterMeters: (map['perimeterMeters'] ?? map['perimeter_meters'] as num?)?.toDouble(),
      landUse: map['landUse'] ?? map['land_use'] ?? 'RESIDENTIAL',
      plotType: map['plotType'] ?? map['plot_type'] ?? 'STANDARD',
      listPrice: listP,
      discountAmount: disc,
      sellingPrice: sellP,
      requiredDeposit: (map['requiredDeposit'] ?? map['required_deposit'] as num?)?.toDouble() ?? 0.0,
      installmentTermsMonths: map['installmentTermsMonths'] ?? map['installment_terms_months'] ?? 12,
      availabilityStatus: map['availabilityStatus'] ?? map['availability_status'] ?? 'AVAILABLE',
      surveyStatus: map['surveyStatus'] ?? map['survey_status'] ?? 'NOT_STARTED',
      bitconStatus: map['bitconStatus'] ?? map['bitcon_status'] ?? 'NOT_STARTED',
      halmashauriStatus: map['halmashauriStatus'] ?? map['halmashauri_status'] ?? 'NOT_STARTED',
      titleStatus: map['titleStatus'] ?? map['title_status'] ?? 'NOT_STARTED',
      currentCustomerId: map['currentCustomerId'] ?? map['current_customer_id'],
      currentBookingId: map['currentBookingId'] ?? map['current_booking_id'],
      currentSaleId: map['currentSaleId'] ?? map['current_sale_id'],
      assignedSalesAgentId: map['assignedSalesAgentId'] ?? map['assigned_sales_agent_id'],
      documents: List<String>.from(map['documents'] ?? []),
      surveyData: map['surveyData'] is Map<String, dynamic> ? map['surveyData'] : {},
      photos: List<String>.from(map['photos'] ?? []),
      notes: map['notes'],
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt']
          : DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plotId': plotId,
      'plotNumber': plotNumber,
      'blockName': blockName,
      'projectId': projectId,
      'branchId': branchId,
      'region': region,
      'district': district,
      'ward': ward,
      'villageStreet': villageStreet,
      'locationDescription': locationDescription,
      'gpsLatitude': gpsLatitude,
      'gpsLongitude': gpsLongitude,
      'boundaryCoordinates': boundaryCoordinates,
      'areaSqm': areaSqm,
      'perimeterMeters': perimeterMeters,
      'landUse': landUse,
      'plotType': plotType,
      'listPrice': listPrice,
      'discountAmount': discountAmount,
      'sellingPrice': sellingPrice,
      'requiredDeposit': requiredDeposit,
      'installmentTermsMonths': installmentTermsMonths,
      'availabilityStatus': availabilityStatus,
      'surveyStatus': surveyStatus,
      'bitconStatus': bitconStatus,
      'halmashauriStatus': halmashauriStatus,
      'titleStatus': titleStatus,
      'currentCustomerId': currentCustomerId,
      'currentBookingId': currentBookingId,
      'currentSaleId': currentSaleId,
      'assignedSalesAgentId': assignedSalesAgentId,
      'documents': documents,
      'surveyData': surveyData,
      'photos': photos,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
