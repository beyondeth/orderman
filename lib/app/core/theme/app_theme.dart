import 'package:flutter/material.dart';
import 'app_typography.dart';
import 'app_spacing.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Material Design 3 ColorScheme
      colorScheme: AppColors.lightColorScheme,

      // Material Design 3 Typography
      textTheme: AppTypography.lightTextTheme,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.appBarTitle.copyWith(
          color: AppColors.lightOnPrimary,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          textStyle: AppTypography.buttonText,
          elevation: 1,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          textStyle: AppTypography.buttonText,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          side: const BorderSide(color: AppColors.lightOutline),
          textStyle: AppTypography.buttonText,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          textStyle: AppTypography.buttonText,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.lightError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.lightError, width: 2),
        ),
        contentPadding: AppSpacing.paddingMD,
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightOnSurfaceVariant,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightOnSurfaceVariant.withOpacity(0.6),
        ),
        filled: true,
        fillColor: AppColors.lightSurfaceVariant.withOpacity(0.1),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 1,
        shadowColor: AppColors.lightOnSurface.withOpacity(0.1),
        surfaceTintColor: AppColors.lightPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        margin: AppSpacing.paddingSM,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.paddingMD,
        titleTextStyle: AppTypography.titleMedium,
        subtitleTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightOnSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.lightOnSurfaceVariant,
        selectedLabelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.labelMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 3,
      ),

      // Navigation Bar Theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.lightPrimaryContainer,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppTypography.labelMedium.copyWith(
              color: AppColors.lightOnSurface,
            );
          }
          return AppTypography.labelMedium.copyWith(
            color: AppColors.lightOnSurfaceVariant,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(
              color: AppColors.lightOnSecondaryContainer,
            );
          }
          return const IconThemeData(color: AppColors.lightOnSurfaceVariant);
        }),
        height: 80,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.lightOutlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurfaceVariant,
        selectedColor: AppColors.lightSecondaryContainer,
        labelStyle: AppTypography.labelMedium,
        padding: AppSpacing.paddingSM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: AppColors.lightPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        titleTextStyle: AppTypography.headlineSmall,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightOnSurface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.lightSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      // Material Design 3 ColorScheme
      colorScheme: AppColors.darkColorScheme,

      // Material Design 3 Typography (Dark)
      textTheme: AppTypography.darkTextTheme,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.appBarTitle.copyWith(
          color: AppColors.darkOnSurface,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          textStyle: AppTypography.buttonText,
          elevation: 1,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          textStyle: AppTypography.buttonText,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          side: const BorderSide(color: AppColors.darkOutline),
          textStyle: AppTypography.buttonText,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          textStyle: AppTypography.buttonText,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.darkError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.darkError, width: 2),
        ),
        contentPadding: AppSpacing.paddingMD,
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkOnSurfaceVariant,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkOnSurfaceVariant.withOpacity(0.6),
        ),
        filled: true,
        fillColor: AppColors.darkSurfaceVariant.withOpacity(0.1),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: AppColors.darkPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        margin: AppSpacing.paddingSM,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.paddingMD,
        titleTextStyle: AppTypography.titleMedium.copyWith(
          color: AppColors.darkOnSurface,
        ),
        subtitleTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkOnSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkOnSurfaceVariant,
        selectedLabelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.labelMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 3,
      ),

      // Navigation Bar Theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.darkPrimaryContainer,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppTypography.labelMedium.copyWith(
              color: AppColors.darkOnSurface,
            );
          }
          return AppTypography.labelMedium.copyWith(
            color: AppColors.darkOnSurfaceVariant,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(
              color: AppColors.darkOnSecondaryContainer,
            );
          }
          return const IconThemeData(color: AppColors.darkOnSurfaceVariant);
        }),
        height: 80,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.darkOutlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.darkSecondaryContainer,
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.darkOnSurface,
        ),
        padding: AppSpacing.paddingSM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: AppColors.darkPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.darkOnSurface,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkOnSurface,
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkOnSurface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
