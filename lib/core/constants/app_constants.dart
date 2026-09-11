import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'POWER FAMILY';
  static const String companyName = 'Power Family Investment Ltd';
  static const String appTagline = 'Business Management System';

  // User Roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleBranchManager = 'branch_manager';
  static const String roleSalesAgent = 'sales_agent';
  static const String roleSurveyor = 'surveyor';

  static const List<String> allRoles = [
    roleSuperAdmin,
    roleBranchManager,
    roleSalesAgent,
    roleSurveyor,
  ];

  static String getRoleLabel(String role) {
    switch (role) {
      case roleSuperAdmin:
        return 'Super Admin';
      case roleBranchManager:
        return 'Branch Manager';
      case roleSalesAgent:
        return 'Sales Agent';
      case roleSurveyor:
        return 'Surveyor';
      default:
        return 'Staff Member';
    }
  }

  // Account Statuses
  static const String statusActive = 'active';
  static const String statusPending = 'pending';
  static const String statusSuspended = 'suspended';
  static const String statusDisabled = 'disabled';

  // Branch Statuses
  static const String branchActive = 'active';
  static const String branchInactive = 'inactive';

  // Property Types
  static const String typeKiwanja = 'kiwanja';
  static const String typeNyumba = 'nyumba';
  static const String typeGari = 'gari';

  static String getPropertyTypeLabel(String type) {
    switch (type) {
      case typeKiwanja:
        return 'Kiwanja (Land)';
      case typeNyumba:
        return 'Nyumba (House)';
      case typeGari:
        return 'Gari (Vehicle)';
      default:
        return type;
    }
  }

  // Property Statuses
  static const String propertyAvailable = 'available';
  static const String propertyReserved = 'reserved';
  static const String propertySold = 'sold';
  static const String propertyInactive = 'inactive';
  static const String propertyUnderProcess = 'under_process';
  static const String propertySurveying = 'surveying';
  static const String propertySurveyed = 'surveyed';
  static const String propertyRegistrationInProgress = 'registration_in_progress';
  static const String propertyRegistered = 'registered';

  // Customer Statuses
  static const String customerNew = 'new';
  static const String customerContacted = 'contacted';
  static const String customerInterested = 'interested';
  static const String customerNegotiating = 'negotiating';
  static const String customerConverted = 'converted';
  static const String customerLost = 'lost';

  // Lead Statuses
  static const String leadNew = 'new';
  static const String leadContacted = 'contacted';
  static const String leadInterested = 'interested';
  static const String leadNegotiating = 'negotiating';
  static const String leadConverted = 'converted';
  static const String leadLost = 'lost';

  // Sale Payment Statuses
  static const String paymentPending = 'pending';
  static const String paymentPartial = 'partial';
  static const String paymentPaid = 'paid';

  // Sale Statuses
  static const String salePending = 'pending';
  static const String saleCompleted = 'completed';
  static const String saleCancelled = 'cancelled';

  // Survey Task Statuses
  static const String surveyAssigned = 'assigned';
  static const String surveyInProgress = 'in_progress';
  static const String surveyCompleted = 'completed';
  static const String surveyOnHold = 'on_hold';
  static const String surveyCancelled = 'cancelled';
}
