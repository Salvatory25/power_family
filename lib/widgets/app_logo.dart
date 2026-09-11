import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDarkBackground;
  final bool isVertical;

  const AppLogo({
    super.key,
    this.size = 56.0,
    this.showText = false,
    this.isDarkBackground = false,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final emblem = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.06),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.accent,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.35),
            blurRadius: size * 0.3,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: size * 0.2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.accent.withOpacity(0.4), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.logoMaroon,
              padding: EdgeInsets.all(size * 0.12),
              child: Center(
                child: Icon(
                  Icons.apartment_rounded,
                  size: size * 0.5,
                  color: AppColors.logoGold,
                ),
              ),
            );
          },
        ),
      ),
    );

    if (!showText) return emblem;

    final textWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isVertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'POWER FAMILY',
          style: TextStyle(
            fontSize: isVertical ? size * 0.32 : size * 0.28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            height: 1.1,
            color: isDarkBackground ? Colors.white : AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: isVertical
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 3)
              : EdgeInsets.zero,
          decoration: isVertical
              ? BoxDecoration(
                  color: AppColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Text(
            'INVESTMENT LTD',
            style: TextStyle(
              fontSize: isVertical ? size * 0.18 : size * 0.2,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          emblem,
          SizedBox(height: size * 0.25),
          textWidget,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emblem,
        SizedBox(width: size * 0.22),
        textWidget,
      ],
    );
  }
}

