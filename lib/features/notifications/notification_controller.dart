import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/notification_model.dart';
import '../../repositories/notification_repository.dart';
import '../auth/auth_controller.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

// Stream of notifications for the current user
final notificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) {
    return const Stream.empty();
  }
  
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.streamNotifications(user.uid);
});

// Derived provider for unread count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsStreamProvider).value;
  if (notifications == null) return 0;
  return notifications.where((n) => !n.isRead).length;
});

class NotificationController extends StateNotifier<AsyncValue<void>> {
  final NotificationRepository _repository;

  NotificationController(this._repository) : super(const AsyncValue.data(null));

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      state = const AsyncValue.loading();
      await _repository.markAllAsRead(userId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final notificationControllerProvider = StateNotifierProvider<NotificationController, AsyncValue<void>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationController(repository);
});
