import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/app_logo.dart';
import 'auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _submitted = false;
  bool _isLoading = false;

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (Formatters.validateEmail(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid corporate email.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
    setState(() {
      _isLoading = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),

              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accent.withOpacity(0.18),
                            AppColors.primary.withOpacity(0.04),
                            Colors.transparent,
                          ],
                          stops: const [0.2, 0.6, 1.0],
                        ),
                      ),
                    ),
                    const AppLogo(
                      size: 80,
                      showText: true,
                      isVertical: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border.withOpacity(0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(28.0),
                child: _submitted
                    ? Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.statusAvailable.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.statusAvailable),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Reset Link Sent!',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'We have sent a password reset link to ${_emailController.text}. Please check your inbox.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary.withOpacity(0.9), height: 1.4),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () => context.pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                              ),
                              child: const Text('Back to Login', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Password Reset',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Enter your corporate email address to receive password reset instructions.',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary.withOpacity(0.9), height: 1.4),
                          ),
                          const SizedBox(height: 28),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Corporate Email',
                              hintText: 'name@powerfamily.co.tz',
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.accent, size: 22),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.accent, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleReset,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: AppColors.accent.withOpacity(0.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : const Text(
                                      'Send Reset Link',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                    ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

