import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // Stream notifications for real-time updates
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => NotificationModel.fromJson(e)).toList());
  }
  // Create a new notification
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _supabase.from('notifications').insert(notification.toJson());
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Notify admins and branch manager via RPC
  Future<void> notifyAdminsAndManager({
    required String branchId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      await _supabase.rpc('notify_admins_and_manager', params: {
        'p_branch_id': branchId,
        'p_title': title,
        'p_message': message,
        'p_type': type,
      });
    } catch (e) {
      throw Exception('Failed to notify admins: $e');
    }
  }

  // Fetch notifications once
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (response as List).map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all unread notifications for a user as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }
}
