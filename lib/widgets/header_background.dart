import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class HeaderBackground extends StatelessWidget {
  final double height;
  final Widget child;

  const HeaderBackground({
    super.key,
    this.height = 250,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF1E3A8A)], // Deep blue gradient matching customer dashboard
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: child,
    );
  }
}
