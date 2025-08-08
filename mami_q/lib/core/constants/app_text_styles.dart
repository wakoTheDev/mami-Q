import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display Styles
  static TextStyle displayLarge = const TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: AppColors.textPrimary,
    height: 1.12,
  );
  
  static TextStyle displayMedium = const TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: AppColors.textPrimary,
    height: 1.16,
  );
  
  static TextStyle displaySmall = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: AppColors.textPrimary,
    height: 1.22,
  );
  
  // Headline Styles
  static TextStyle headlineLarge = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: AppColors.textPrimary,
    height: 1.25,
  );
  
  static TextStyle headlineMedium = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: AppColors.textPrimary,
    height: 1.29,
  );
  
  static TextStyle headlineSmall = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: AppColors.textPrimary,
    height: 1.33,
  );
  
  // Title Styles
  static TextStyle titleLarge = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: AppColors.textPrimary,
    height: 1.27,
  );
  
  static TextStyle titleMedium = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static TextStyle titleSmall = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: AppColors.textPrimary,
    height: 1.43,
  );
  
  // Body Styles
  static TextStyle bodyLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static TextStyle bodyMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: AppColors.textSecondary,
    height: 1.43,
  );
  
  static TextStyle bodySmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: AppColors.textTertiary,
    height: 1.33,
  );
  
  // Label Styles
  static TextStyle labelLarge = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: AppColors.textPrimary,
    height: 1.43,
  );
  
  static TextStyle labelMedium = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: AppColors.textSecondary,
    height: 1.33,
  );
  
  static TextStyle labelSmall = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: AppColors.textTertiary,
    height: 1.45,
  );
  
  // Button Styles
  static TextStyle buttonLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: AppColors.textOnPrimary,
    height: 1.5,
  );
  
  static TextStyle buttonMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: AppColors.textOnPrimary,
    height: 1.43,
  );
  
  static TextStyle buttonSmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: AppColors.textOnPrimary,
    height: 1.33,
  );
  
  // Special Styles
  static TextStyle caption = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
    color: AppColors.textTertiary,
    height: 1.6,
  );
  
  static TextStyle overline = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: 1.5,
  );
  
  // Custom App Styles
  static TextStyle pregnancyWeek = const TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: AppColors.primary,
    height: 1.0,
  );
  
  static TextStyle tokenCount = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: AppColors.tokenGold,
    height: 1.2,
  );
  
  static TextStyle emergencyButton = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
    color: AppColors.white,
    height: 1.2,
  );
  
  static TextStyle milestoneTitle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: AppColors.primary,
    height: 1.3,
  );
}

class AppTextTheme {
  static TextTheme get textTheme => TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    displaySmall: AppTextStyles.displaySmall,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    headlineSmall: AppTextStyles.headlineSmall,
    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    titleSmall: AppTextStyles.titleSmall,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
  );
}
