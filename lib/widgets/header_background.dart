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
      color: const Color(0xFF0F172A),
      child: Stack(
        children: [
          // Background Real Estate Image with Web Graceful Fallback
          Positioned.fill(
            child: Image.asset(
              'assets/images/header_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient,
                  ),
                );
              },
            ),
          ),
          // Deep Navy Slate Gradient Filter Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F172A).withOpacity(0.88),
                    const Color(0xFF1E293B).withOpacity(0.82),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Content Layer
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
