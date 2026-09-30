import 'package:flutter/foundation.dart';
import '../../models/notification_model.dart';
import '../../repositories/notification_repository.dart';
import 'email_service_io.dart';

class KikobaNotificationService {
  final NotificationRepository _notificationRepo;

  KikobaNotificationService(this._notificationRepo);

  /// Event: KIKOBA_APPLIED
  /// Sends notification to Customer and Admin
  Future<void> notifyKikobaApplied({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String serviceName,
    required String planName,
  }) async {
    // 1. Notify Customer via Email
    if (customerEmail.isNotEmpty) {
      // For now using welcome email structure, but you can build a dedicated template
      // Alternatively, we just send a direct email string if we implement a custom template
      debugPrint('Simulating Email to Customer: Your application for $serviceName ($planName) is received.');
    }

    // 2. Notify Customer In-App
    await _notificationRepo.createNotification(
      NotificationModel(
        id: '',
        userId: customerId,
        title: 'Kikoba Application Received',
        message: 'Your application for $serviceName ($planName) has been received and is pending approval.',
        type: 'KIKOBA_APPLIED',
        createdAt: DateTime.now(),
      ),
    );

    // 3. Notify Admins In-App (Assuming branchId 'HQ' or general admins)
    try {
      await _notificationRepo.notifyAdminsAndManager(
        branchId: 'HQ', // Change based on logic
        title: 'New Kikoba Application',
        message: '$customerName applied for $serviceName ($planName).',
        type: 'KIKOBA_APPLIED',
      );
    } catch (e) {
      debugPrint('Admin notification failed (might need RPC setup): $e');
    }
  }

  /// Event: KIKOBA_APPROVED
  /// Sends notification to Customer only
  Future<void> notifyKikobaApproved({
    required String customerId,
    required String customerEmail,
    required String kikobaNumber,
    required String serviceName,
  }) async {
    // 1. Email Customer
    if (customerEmail.isNotEmpty) {
      debugPrint('Simulating Email to Customer: Your Kikoba $kikobaNumber for $serviceName is APPROVED.');
    }

    // 2. In-App Notification
    await _notificationRepo.createNotification(
      NotificationModel(
        id: '',
        userId: customerId,
        title: 'Kikoba Approved! 🎉',
        message: 'Your Kikoba $kikobaNumber for $serviceName has been approved. You can now start paying.',
        type: 'KIKOBA_APPROVED',
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Event: KIKOBA_REJECTED
  Future<void> notifyKikobaRejected({
    required String customerId,
    required String serviceName,
    required String reason,
  }) async {
    await _notificationRepo.createNotification(
      NotificationModel(
        id: '',
        userId: customerId,
        title: 'Kikoba Application Status',
        message: 'Your application for $serviceName was not approved. Reason: $reason',
        type: 'KIKOBA_REJECTED',
        createdAt: DateTime.now(),
      ),
    );
  }
}
