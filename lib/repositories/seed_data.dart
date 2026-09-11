import '../models/user_model.dart';
import '../models/branch_model.dart';
import '../models/property_model.dart';
import '../models/customer_model.dart';
import '../models/lead_model.dart';
import '../models/sale_model.dart';
import '../models/survey_task_model.dart';
import '../models/sms_log_model.dart';
import '../models/activity_model.dart';
import '../core/constants/app_constants.dart';

class SeedData {
  static final DateTime now = DateTime.now();

  // Branches
  static final List<BranchModel> branches = [
    BranchModel(
      id: 'branch_dar',
      name: 'Dar es Salaam HQ',
      code: 'PF-DAR',
      location: 'Victoria, Bagamoyo Road, Dar es Salaam',
      phone: '+255 712 000 111',
      email: 'dar@powerfamily.co.tz',
      managerId: 'user_bm_dar',
      status: AppConstants.branchActive,
      createdAt: now.subtract(const Duration(days: 365)),
      updatedAt: now,
    ),
    BranchModel(
      id: 'branch_arusha',
      name: 'Arusha Branch',
      code: 'PF-ARS',
      location: 'Njiro Road, Arusha',
      phone: '+255 754 000 222',
      email: 'arusha@powerfamily.co.tz',
      managerId: 'user_bm_arusha',
      status: AppConstants.branchActive,
      createdAt: now.subtract(const Duration(days: 200)),
      updatedAt: now,
    ),
  ];

  // Users (Demo Accounts for each role)
  static final List<UserModel> users = [
    UserModel(
      uid: 'user_admin',
      fullName: 'Super Admin',
      email: 'admin@powerfamily.co.tz',
      phone: '+255 700 111 222',
      role: AppConstants.roleSuperAdmin,
      branchId: 'branch_dar',
      status: AppConstants.statusActive,
      createdAt: now.subtract(const Duration(days: 365)),
      updatedAt: now,
    ),
    UserModel(
      uid: 'user_bm_dar',
      fullName: 'Manager Dar es Salaam',
      email: 'manager.dar@powerfamily.co.tz',
      phone: '+255 712 333 444',
      role: AppConstants.roleBranchManager,
      branchId: 'branch_dar',
      status: AppConstants.statusActive,
      createdAt: now.subtract(const Duration(days: 300)),
      updatedAt: now,
    ),
    UserModel(
      uid: 'user_bm_arusha',
      fullName: 'Manager Arusha',
      email: 'manager.arusha@powerfamily.co.tz',
      phone: '+255 754 555 666',
      role: AppConstants.roleBranchManager,
      branchId: 'branch_arusha',
      status: AppConstants.statusActive,
      createdAt: now.subtract(const Duration(days: 180)),
      updatedAt: now,
    ),
    UserModel(
      uid: 'user_agent_1',
      fullName: 'Sales Agent (Dar)',
      email: 'agent1@powerfamily.co.tz',
      phone: '+255 768 777 888',
      role: AppConstants.roleSalesAgent,
      branchId: 'branch_dar',
      status: AppConstants.statusActive,
      createdAt: now.subtract(const Duration(days: 120)),
      updatedAt: now,
    ),
    UserModel(
      uid: 'user_surveyor_1',
      fullName: 'Surveyor Expert',
      email: 'surveyor1@powerfamily.co.tz',
      phone: '+255 789 999 000',
      role: AppConstants.roleSurveyor,
      branchId: 'branch_dar',
      status: AppConstants.statusActive,
      createdAt: now.subtract(const Duration(days: 90)),
      updatedAt: now,
    ),
    UserModel(
      uid: 'user_pending_1',
      fullName: 'New Staff Applicant',
      email: 'pending@powerfamily.co.tz',
      phone: '+255 655 123 456',
      role: AppConstants.roleSalesAgent,
      branchId: 'branch_arusha',
      status: AppConstants.statusPending,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now,
    ),
  ];

  // Properties (Viwanja, Nyumba, Magari)
  static final List<PropertyModel> properties = [
    // 1. Viwanja (Land)
    PropertyModel(
      id: 'prop_kiwanja_1',
      propertyCode: 'PF-KW-001',
      title: 'Prime Commercial Plot Kigamboni',
      type: AppConstants.typeKiwanja,
      description: 'Prime surveyed commercial land located 500 meters from main Bagamoyo road junction. Ideal for residential estate or commercial plaza.',
      price: 45000000.0, // 45M TZS
      location: 'Kigamboni, Dar es Salaam',
      region: 'Dar es Salaam',
      district: 'Kigamboni',
      ward: 'Kimbiji',
      street: 'Mjimwema',
      size: '600 SQM',
      plotNumber: '142',
      blockNumber: 'Block C',
      landUse: 'Residential / Commercial',
      surveyStatus: 'Surveyed',
      registrationStatus: 'Title Deed Ready',
      latitude: -6.8167,
      longitude: 39.2833,
      images: [
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=80',
        'https://images.unsplash.com/photo-1524813686514-a57563d77965?w=800&q=80'
      ],
      documents: ['Title_Deed_Kigamboni_142.pdf', 'Survey_Plan_Block_C.pdf'],
      status: AppConstants.propertyAvailable,
      branchId: 'branch_dar',
      assignedAgentId: 'user_agent_1',
      assignedSurveyorId: 'user_surveyor_1',
      createdBy: 'user_admin',
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now,
    ),
    PropertyModel(
      id: 'prop_kiwanja_2',
      propertyCode: 'PF-KW-002',
      title: 'Residential Plot Njiro Arusha',
      type: AppConstants.typeKiwanja,
      description: 'Scenic residential plot with Mount Meru view, water and electricity infrastructure available on site.',
      price: 28000000.0, // 28M TZS
      location: 'Njiro Block D, Arusha',
      region: 'Arusha',
      district: 'Arusha City',
      ward: 'Njiro',
      street: 'Vianzi',
      size: '800 SQM',
      plotNumber: '89',
      blockNumber: 'Block D',
      landUse: 'Residential',
      surveyStatus: 'Surveying',
      registrationStatus: 'Processing',
      latitude: -3.3667,
      longitude: 36.6833,
      images: [
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=80'
      ],
      documents: ['Plot_Offer_Letter.pdf'],
      status: AppConstants.propertyUnderProcess,
      branchId: 'branch_arusha',
      assignedAgentId: 'user_bm_arusha',
      assignedSurveyorId: 'user_surveyor_1',
      createdBy: 'user_bm_arusha',
      createdAt: now.subtract(const Duration(days: 45)),
      updatedAt: now,
    ),
    PropertyModel(
      id: 'prop_kiwanja_3',
      propertyCode: 'PF-KW-003',
      title: 'Beachfront Land Bagamoyo',
      type: AppConstants.typeKiwanja,
      description: 'Exclusive 1,500 SQM beachfront land ideal for luxury resort or private mansion development.',
      price: 120000000.0, // 120M TZS
      location: 'Kaole, Bagamoyo',
      region: 'Pwani',
      district: 'Bagamoyo',
      ward: 'Kaole',
      size: '1500 SQM',
      plotNumber: '12',
      blockNumber: 'Beachfront Sec 1',
      landUse: 'Hospitality / Resort',
      surveyStatus: 'Surveyed',
      registrationStatus: 'Title Deed Ready',
      images: [
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80'
      ],
      documents: ['Beachfront_Survey_Doc.pdf'],
      status: AppConstants.propertyReserved,
      branchId: 'branch_dar',
      assignedAgentId: 'user_agent_1',
      createdBy: 'user_admin',
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now,
    ),

    // 2. Nyumba (Houses)
    PropertyModel(
      id: 'prop_nyumba_1',
      propertyCode: 'PF-HB-001',
      title: 'Modern 4 Bedroom Villa Mbezi Beach',
      type: AppConstants.typeNyumba,
      description: 'Luxury 4-bedroom standalone villa featuring master suite, private swimming pool, landscaped garden, and security fence.',
      price: 350000000.0, // 350M TZS
      location: 'Mbezi Beach Africana, Dar es Salaam',
      region: 'Dar es Salaam',
      district: 'Kinondoni',
      ward: 'Mbezi Beach',
      size: '1000 SQM Plot / 350 SQM House',
      bedrooms: 4,
      bathrooms: 4,
      images: [
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=80'
      ],
      documents: ['Villa_Occupancy_Permit.pdf'],
      status: AppConstants.propertyAvailable,
      branchId: 'branch_dar',
      assignedAgentId: 'user_agent_1',
      createdBy: 'user_admin',
      createdAt: now.subtract(const Duration(days: 90)),
      updatedAt: now,
    ),
    PropertyModel(
      id: 'prop_nyumba_2',
      propertyCode: 'PF-HB-002',
      title: '3 Bedroom Townhouse Kisongo Arusha',
      type: AppConstants.typeNyumba,
      description: 'Family townhouse with solar backup, automated gate, modern kitchen, and paved compound.',
      price: 185000000.0, // 185M TZS
      location: 'Kisongo Estate, Arusha',
      region: 'Arusha',
      district: 'Arusha',
      bedrooms: 3,
      bathrooms: 2,
      images: [
        'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800&q=80'
      ],
      documents: ['Townhouse_Deed.pdf'],
      status: AppConstants.propertySold,
      branchId: 'branch_arusha',
      assignedAgentId: 'user_bm_arusha',
      createdBy: 'user_bm_arusha',
      createdAt: now.subtract(const Duration(days: 120)),
      updatedAt: now,
    ),

    // 3. Magari (Vehicles)
    PropertyModel(
      id: 'prop_gari_1',
      propertyCode: 'PF-VG-001',
      title: 'Toyota Land Cruiser V8 (2020)',
      type: AppConstants.typeGari,
      description: 'Immaculate 2020 Toyota Land Cruiser V8 ZX, leather interior, sunroof, full service history at Toyota Tanzania.',
      price: 195000000.0, // 195M TZS
      location: 'Dar es Salaam HQ Showroom',
      region: 'Dar es Salaam',
      district: 'Kinondoni',
      vehicleMake: 'Toyota',
      vehicleModel: 'Land Cruiser V8 ZX',
      vehicleYear: 2020,
      vehicleRegistration: 'T 884 EFG',
      vehicleMileage: '42,000 KM',
      vehicleCondition: 'Excellent',
      images: [
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800&q=80'
      ],
      documents: ['Logbook_T884EFG.pdf', 'TRA_Tax_Clearance.pdf'],
      status: AppConstants.propertyAvailable,
      branchId: 'branch_dar',
      assignedAgentId: 'user_agent_1',
      createdBy: 'user_admin',
      createdAt: now.subtract(const Duration(days: 15)),
      updatedAt: now,
    ),
    PropertyModel(
      id: 'prop_gari_2',
      propertyCode: 'PF-VG-002',
      title: 'Toyota Hilux Double Cab (2021)',
      type: AppConstants.typeGari,
      description: 'Reliable 4x4 survey & site inspection utility vehicle equipped with off-road tires and canopy.',
      price: 85000000.0, // 85M TZS
      location: 'Arusha Branch Yard',
      region: 'Arusha',
      district: 'Arusha',
      vehicleMake: 'Toyota',
      vehicleModel: 'Hilux Revo 4x4',
      vehicleYear: 2021,
      vehicleRegistration: 'T 412 DSK',
      vehicleMileage: '65,000 KM',
      vehicleCondition: 'Good',
      images: [
        'https://images.unsplash.com/photo-1559416523-140ddc3d238c?w=800&q=80'
      ],
      documents: ['Logbook_T412DSK.pdf'],
      status: AppConstants.propertyAvailable,
      branchId: 'branch_arusha',
      assignedAgentId: 'user_bm_arusha',
      createdBy: 'user_bm_arusha',
      createdAt: now.subtract(const Duration(days: 25)),
      updatedAt: now,
    ),
  ];

  // Customers
  static final List<CustomerModel> customers = [
    CustomerModel(
      id: 'cust_1',
      fullName: 'Hon. Juma Rashid',
      phone: '+255 715 888 999',
      email: 'juma.rashid@gmail.com',
      address: 'Mikocheni B, Dar es Salaam',
      notes: 'Interested in buying commercial plot in Kigamboni. Has cash ready.',
      interestedPropertyTypes: [AppConstants.typeKiwanja, AppConstants.typeNyumba],
      budget: 100000000.0,
      status: AppConstants.customerNegotiating,
      assignedAgentId: 'user_agent_1',
      branchId: 'branch_dar',
      createdBy: 'user_agent_1',
      createdAt: now.subtract(const Duration(days: 40)),
      updatedAt: now,
    ),
    CustomerModel(
      id: 'cust_2',
      fullName: 'Grace Mussa',
      phone: '+255 754 112 233',
      email: 'grace.mussa@yahoo.com',
      address: 'Njiro, Arusha',
      notes: 'Looking for 3-bedroom residential house in Arusha or plot for building.',
      interestedPropertyTypes: [AppConstants.typeNyumba],
      budget: 200000000.0,
      status: AppConstants.customerConverted,
      assignedAgentId: 'user_bm_arusha',
      branchId: 'branch_arusha',
      createdBy: 'user_bm_arusha',
      createdAt: now.subtract(const Duration(days: 80)),
      updatedAt: now,
    ),
    CustomerModel(
      id: 'cust_3',
      fullName: 'Eng. Edward Kimaro',
      phone: '+255 787 554 433',
      email: 'edward@kimaroconsulting.com',
      address: 'Upanga, Dar es Salaam',
      notes: 'Searching for Land Cruiser V8 or Hilux for company executive fleet.',
      interestedPropertyTypes: [AppConstants.typeGari],
      budget: 200000000.0,
      status: AppConstants.customerInterested,
      assignedAgentId: 'user_agent_1',
      branchId: 'branch_dar',
      createdBy: 'user_agent_1',
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now,
    ),
  ];

  // Leads
  static final List<LeadModel> leads = [
    LeadModel(
      id: 'lead_1',
      customerId: 'cust_1',
      propertyId: 'prop_kiwanja_1',
      assignedAgentId: 'user_agent_1',
      branchId: 'branch_dar',
      source: 'Website Inquiry',
      status: AppConstants.leadNegotiating,
      notes: 'Customer conducted site visit on Sunday. Requested 5% discount on 45M TZS price.',
      nextFollowUp: now.add(const Duration(days: 2)),
      createdBy: 'user_agent_1',
      createdAt: now.subtract(const Duration(days: 15)),
      updatedAt: now,
    ),
    LeadModel(
      id: 'lead_2',
      customerId: 'cust_3',
      propertyId: 'prop_gari_1',
      assignedAgentId: 'user_agent_1',
      branchId: 'branch_dar',
      source: 'Direct Phone Call',
      status: AppConstants.leadInterested,
      notes: 'Customer requested inspection report and vehicle test drive at HQ showroom.',
      nextFollowUp: now.add(const Duration(days: 1)),
      createdBy: 'user_agent_1',
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now,
    ),
  ];

  // Sales Records
  static final List<SaleModel> sales = [
    SaleModel(
      id: 'sale_1',
      propertyId: 'prop_nyumba_2',
      customerId: 'cust_2',
      agentId: 'user_bm_arusha',
      branchId: 'branch_arusha',
      amount: 185000000.0,
      paymentStatus: AppConstants.paymentPaid,
      saleStatus: AppConstants.saleCompleted,
      notes: 'Full payment completed via bank transfer. House ownership documents transferred.',
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now.subtract(const Duration(days: 60)),
    ),
  ];

  // Survey Tasks (Land Urasimishaji)
  static final List<SurveyTaskModel> surveyTasks = [
    SurveyTaskModel(
      id: 'survey_task_1',
      propertyId: 'prop_kiwanja_2',
      surveyorId: 'user_surveyor_1',
      branchId: 'branch_arusha',
      status: AppConstants.surveyInProgress,
      deadline: now.add(const Duration(days: 7)),
      notes: 'Boundary beacons placement in progress. Final survey map submission pending ministry approval.',
      documents: ['Beacon_Coordinates_Sheet.pdf'],
      createdAt: now.subtract(const Duration(days: 14)),
      updatedAt: now,
    ),
  ];

  // SMS Logs
  static final List<SMSLogModel> smsLogs = [
    SMSLogModel(
      id: 'sms_1',
      recipientId: 'cust_1',
      phoneNumber: '+255 715 888 999',
      message: 'Habari Hon. Juma, kukiwa na sasisho kuhusu Kiwanja Kigamboni (PF-KW-001), tafadhali tuwasiliane. Power Family Investment Ltd.',
      sentBy: 'user_agent_1',
      branchId: 'branch_dar',
      status: 'sent',
      providerMessageId: 'MSG-884920',
      createdAt: now.subtract(const Duration(days: 3)),
    ),
  ];

  // Activity Log
  static final List<ActivityModel> activities = [
    ActivityModel(
      id: 'act_1',
      actorId: 'user_admin',
      actorName: 'Super Admin',
      action: 'PROPERTY_CREATED',
      entityType: 'Property',
      entityId: 'prop_kiwanja_1',
      description: 'Created new land property PF-KW-001 (Kigamboni Commercial Plot)',
      branchId: 'branch_dar',
      createdAt: now.subtract(const Duration(days: 60)),
    ),
    ActivityModel(
      id: 'act_2',
      actorId: 'user_bm_arusha',
      actorName: 'Manager Arusha',
      action: 'SALE_COMPLETED',
      entityType: 'Sale',
      entityId: 'sale_1',
      description: 'Recorded completed sale for PF-HB-002 (TZS 185,000,000) to Grace Mussa',
      branchId: 'branch_arusha',
      createdAt: now.subtract(const Duration(days: 60)),
    ),
  ];
}
