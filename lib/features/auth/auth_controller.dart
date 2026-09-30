import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/email_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.loading()) {
    init();
  }

  Future<void> init() async {
    try {
      final user = await _repository.getCurrentUserSession();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email: email, password: password);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? requestedRole,
    String? branchId,
    String? region,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        requestedRole: requestedRole,
        branchId: branchId,
        region: region,
      );
      
      // Dispatch Welcome Email
      EmailService.sendWelcomeEmail(email, fullName);

      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    // This tells Supabase to send the 6-digit OTP code to the user's email
    await _repository.sendPasswordResetEmail(email);
  }

  Future<bool> verifyOTPAndResetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      await _repository.verifyOTPAndResetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );
      // Once verified and updated, reload the user session
      final user = await _repository.getCurrentUserSession();
      state = AsyncValue.data(user);
      return true;
    } catch (e) {
      throw e;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }

  void switchDevRole(String role) {
    _repository.switchDevRole(role);
    state = AsyncValue.data(_repository.currentUser);
  }

  Future<bool> updateProfilePicture(List<int> bytes, String extension) async {
    try {
      final user = await _repository.updateProfilePicture(bytes, extension);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      print('Error updating profile picture: $e');
      throw e;
    }
  }

  Future<bool> updateRegion(String region) async {
    try {
      final user = await _repository.updateRegion(region);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      print('Error updating region: $e');
      return false;
    }
  }
}
