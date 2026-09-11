import 'package:flutter/material.dart';

class AppColors {
  // Sleek Deep Navy/Slate & Rich Amber/Gold Corporate Palette
  static const Color primary = Color(0xFF0F172A); // Sleek Deep Navy 900
  static const Color primaryDark = Color(0xFF0B1120); // Dark Slate/Navy
  static const Color primaryLight = Color(0xFF1E293B); // Slate 800
  static const Color accent = Color(0xFFD97706); // Rich Amber/Gold 600
  static const Color accentDark = Color(0xFFB45309); // Amber 700

  // Official Power Family Logo Colors
  static const Color logoMaroon = Color(0xFF7A1215); // Deep Maroon Red
  static const Color logoGold = Color(0xFFC8900E); // Rich Warm Gold

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
  );

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color border = Color(0xFFE2E8F0); // Slate 200 Border

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceVariant = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF374151);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8);

  // Status Colors (Centralized Status Configurations)
  static const Color statusAvailable = Color(0xFF059669); // Emerald Green
  static const Color statusReserved = Color(0xFFD97706); // Amber Orange
  static const Color statusSold = Color(0xFFDC2626); // Crimson Red
  static const Color statusUnderProcess = Color(0xFF2563EB); // Royal Blue
  static const Color statusInactive = Color(0xFF64748B); // Slate Grey
  static const Color statusSurveying = Color(0xFF7C3AED); // Deep Purple
  static const Color statusPending = Color(0xFFEA580C); // Dark Orange

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'active':
      case 'completed':
      case 'paid':
      case 'converted':
        return statusAvailable;
      case 'reserved':
      case 'negotiating':
      case 'partial':
      case 'in_progress':
        return statusReserved;
      case 'sold':
      case 'cancelled':
      case 'lost':
      case 'disabled':
      case 'suspended':
        return statusSold;
      case 'under_process':
      case 'contacted':
      case 'surveyed':
      case 'registered':
        return statusUnderProcess;
      case 'surveying':
      case 'registration_in_progress':
        return statusSurveying;
      case 'pending':
      case 'assigned':
      case 'new':
      case 'interested':
        return statusPending;
      default:
        return statusInactive;
    }
  }

  static Color getStatusBackgroundColor(String status) {
    return getStatusColor(status).withOpacity(0.12);
  }
}
