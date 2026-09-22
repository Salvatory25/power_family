import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'POWER FAMILY';
  static const String companyName = 'Power Family Investment Ltd';
  static const String appTagline = 'Business Management System';

  // Master System Roles
  static const String roleSuperAdmin = 'SUPER_ADMIN';
  static const String roleSystemAdmin = 'SYSTEM_ADMIN';
  static const String roleBranchManager = 'BRANCH_MANAGER';
  static const String roleSalesAgent = 'SALES_AGENT';
  static const String roleCustomer = 'CUSTOMER';

  static const List<String> allRoles = [
    roleSuperAdmin,
    roleSystemAdmin,
    roleBranchManager,
    roleSalesAgent,
    roleCustomer,
  ];

  static String getRoleLabel(String role) {
    switch (role.toUpperCase()) {
      case roleSuperAdmin:
        return 'Super Admin';
      case roleSystemAdmin:
        return 'System Admin (CEO)';
      case roleBranchManager:
        return 'Branch Manager';
      case roleSalesAgent:
        return 'Sales Agent';
      case roleCustomer:
        return 'Customer';
      default:
        return role;
    }
  }

  // Branch Codes
  static const String branchDar = 'PFI-DAR';
  static const String branchKibaha = 'PFI-KIB';
  static const String branchArusha = 'PFI-ARU';
  static const String branchDodoma = 'PFI-DOD';
  static const String branchMorogoro = 'PFI-MOR';
  static const String branchMwanza = 'PFI-MWANZA';

  static const List<String> primaryBranches = [
    branchDar,
    branchKibaha,
    branchArusha,
    branchDodoma,
    branchMorogoro,
    branchMwanza,
  ];

  // Plot / Kiwanja Statuses
  static const String plotAvailable = 'AVAILABLE';
  static const String plotReserved = 'RESERVED';
  static const String plotBooked = 'BOOKED';
  static const String plotSold = 'SOLD';
  static const String plotInstallment = 'INSTALLMENT';
  static const String plotFullyPaid = 'FULLY_PAID';
  static const String plotTransferPending = 'TRANSFER_PENDING';
  static const String plotTitleProcessing = 'TITLE_PROCESSING';
  static const String plotTitleReady = 'TITLE_READY';
  static const String plotHandedOver = 'HANDED_OVER';
  static const String plotCancelled = 'CANCELLED';
  static const String plotBlocked = 'BLOCKED';
  static const String plotDisputed = 'DISPUTED';

  // BITCON Statuses
  static const String bitconPending = 'PENDING';
  static const String bitconInProgress = 'IN_PROGRESS';
  static const String bitconSubmitted = 'SUBMITTED';
  static const String bitconProcessing = 'PROCESSING';
  static const String bitconCompleted = 'COMPLETED';
  static const String bitconRejected = 'REJECTED';
  static const String bitconReturned = 'RETURNED';

  // Halmashauri Statuses
  static const String halmashauriProcessing = 'PROCESSING';
  static const String halmashauriWaitingDocument = 'WAITING_DOCUMENT';
  static const String halmashauriFollowUpRequired = 'FOLLOW_UP_REQUIRED';
  static const String halmashauriReady = 'READY';
  static const String halmashauriCompleted = 'COMPLETED';

  // Title Deed Statuses
  static const String titleApplication = 'APPLICATION';
  static const String titleProcessing = 'PROCESSING';
  static const String titleWaiting = 'WAITING';
  static const String titleReady = 'TITLE_READY';
  static const String titleNotified = 'CUSTOMER_NOTIFIED';
  static const String titleCollected = 'TITLE_COLLECTED';
  static const String titleHandedOver = 'HANDOVER';
  static const String titleCompleted = 'COMPLETED';

  // Payment Statuses
  static const String paymentPending = 'PENDING';
  static const String paymentConfirmed = 'CONFIRMED';
  static const String paymentFailed = 'FAILED';
  static const String paymentVoided = 'VOIDED';
  static const String paymentReversed = 'REVERSED';

  // Compatibility & Record Statuses
  static const String branchActive = 'ACTIVE';
  static const String statusActive = 'ACTIVE';
  static const String statusPending = 'PENDING';
  static const String statusInactive = 'INACTIVE';
  static const String statusSuspended = 'SUSPENDED';
  static const String statusArchived = 'ARCHIVED';
  static const String statusDisabled = 'DISABLED';

  // Property / Asset Types
  static const String typeKiwanja = 'KIWANJA';
  static const String typeNyumba = 'NYUMBA';
  static const String typeGari = 'GARI';

  static String getPropertyTypeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'KIWANJA':
        return 'Kiwanja (Plot)';
      case 'NYUMBA':
        return 'Nyumba (House)';
      case 'GARI':
        return 'Gari (Vehicle)';
      default:
        return type;
    }
  }

  // Property Statuses
  static const String propertyAvailable = 'AVAILABLE';
  static const String propertyReserved = 'RESERVED';
  static const String propertyUnderProcess = 'UNDER_PROCESS';
  static const String propertySold = 'SOLD';
  static const String propertySurveying = 'SURVEYING';
  static const String propertyInactive = 'INACTIVE';

  // Customer & Lead Statuses
  static const String customerNew = 'NEW';
  static const String customerNegotiating = 'NEGOTIATING';
  static const String customerConverted = 'CONVERTED';
  static const String customerInterested = 'INTERESTED';
  static const String leadNew = 'NEW';
  static const String leadContacted = 'CONTACTED';
  static const String leadNegotiating = 'NEGOTIATING';
  static const String leadInterested = 'INTERESTED';
  static const String leadConverted = 'CONVERTED';
  static const String leadLost = 'LOST';

  // Sales & Survey & Payment Statuses
  static const String paymentPaid = 'PAID';
  static const String paymentPartial = 'PARTIAL';
  static const String saleCompleted = 'COMPLETED';
  static const String surveyAssigned = 'ASSIGNED';
  static const String surveyInProgress = 'IN_PROGRESS';
  static const String surveyCompleted = 'COMPLETED';
  static const String surveyOnHold = 'ON_HOLD';
}

