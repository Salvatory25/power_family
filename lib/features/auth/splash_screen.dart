import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/app_logo.dart';
import '../dashboard/dashboard_providers.dart';
import 'auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Intentionally avoiding heavy pre-fetching here to speed up launch time.
    ref.listen(authControllerProvider, (previous, next) {
      if (next.isLoading) return;
      if (_isNavigated) return;
      
      // Delay slightly to ensure animation has time to show at least 1 frame 
      // and give Riverpod/Router a clean tick.
      Future.microtask(() {
        if (!mounted) return;
        setState(() => _isNavigated = true);
        _animController.stop();

        final user = next.value;
        if (!mounted) return;
        if (next.hasError || user == null) {
          context.go('/login');
        } else if (user.status != AppConstants.statusActive) {
          context.go('/account-status');
        } else if (user.role == AppConstants.roleCustomer) {
          context.go('/customer-dashboard');
        } else {
          context.go('/dashboard');
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(
                size: 120,
                showText: true,
                isVertical: true,
                isDarkBackground: true,
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
