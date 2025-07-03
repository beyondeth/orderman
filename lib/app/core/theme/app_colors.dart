import 'package:flutter/material.dart';

/// 앱 전체에서 사용할 일관된 색상 시스템
/// Material Design 3 Color System 기반
class AppColors {
  
  // ============================================================================
  // Primary Colors (브랜드 색상)
  // ============================================================================
  
  /// Primary seed color
  static const Color primarySeed = Color(0xFF2196F3);
  
  // Light theme primary colors
  static const Color lightPrimary = Color(0xFF1976D2);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFD1E4FF);
  static const Color lightOnPrimaryContainer = Color(0xFF001D36);
  
  // Dark theme primary colors
  static const Color darkPrimary = Color(0xFF9ECAFF);
  static const Color darkOnPrimary = Color(0xFF003258);
  static const Color darkPrimaryContainer = Color(0xFF00497D);
  static const Color darkOnPrimaryContainer = Color(0xFFD1E4FF);
  
  // ============================================================================
  // Secondary Colors (보조 색상)
  // ============================================================================
  
  // Light theme secondary colors
  static const Color lightSecondary = Color(0xFF535F70);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFD7E3F7);
  static const Color lightOnSecondaryContainer = Color(0xFF101C2B);
  
  // Dark theme secondary colors
  static const Color darkSecondary = Color(0xFFBBC7DB);
  static const Color darkOnSecondary = Color(0xFF253140);
  static const Color darkSecondaryContainer = Color(0xFF3B4858);
  static const Color darkOnSecondaryContainer = Color(0xFFD7E3F7);
  
  // ============================================================================
  // Tertiary Colors (3차 색상)
  // ============================================================================
  
  // Light theme tertiary colors
  static const Color lightTertiary = Color(0xFF6B5778);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFF2DAFF);
  static const Color lightOnTertiaryContainer = Color(0xFF251431);
  
  // Dark theme tertiary colors
  static const Color darkTertiary = Color(0xFFD6BEE4);
  static const Color darkOnTertiary = Color(0xFF3B2948);
  static const Color darkTertiaryContainer = Color(0xFF523F5F);
  static const Color darkOnTertiaryContainer = Color(0xFFF2DAFF);
  
  // ============================================================================
  // Error Colors (에러 색상)
  // ============================================================================
  
  // Light theme error colors
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF410002);
  
  // Dark theme error colors
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);
  
  // ============================================================================
  // Surface Colors (표면 색상)
  // ============================================================================
  
  // Light theme surface colors
  static const Color lightBackground = Color(0xFFFDFCFF);
  static const Color lightOnBackground = Color(0xFF1A1C1E);
  static const Color lightSurface = Color(0xFFFDFCFF);
  static const Color lightOnSurface = Color(0xFF1A1C1E);
  static const Color lightSurfaceVariant = Color(0xFFDFE2EB);
  static const Color lightOnSurfaceVariant = Color(0xFF43474E);
  
  // Dark theme surface colors
  static const Color darkBackground = Color(0xFF111318);
  static const Color darkOnBackground = Color(0xFFE2E2E9);
  static const Color darkSurface = Color(0xFF111318);
  static const Color darkOnSurface = Color(0xFFE2E2E9);
  static const Color darkSurfaceVariant = Color(0xFF43474E);
  static const Color darkOnSurfaceVariant = Color(0xFFC3C7CF);
  
  // ============================================================================
  // Outline Colors (윤곽선 색상)
  // ============================================================================
  
  static const Color lightOutline = Color(0xFF73777F);
  static const Color lightOutlineVariant = Color(0xFFC3C7CF);
  static const Color darkOutline = Color(0xFF8D9199);
  static const Color darkOutlineVariant = Color(0xFF43474E);
  
  // ============================================================================
  // Semantic Colors (의미적 색상)
  // ============================================================================
  
  /// Success colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successContainer = Color(0xFFE8F5E8);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF1B5E20);
  
  /// Warning colors
  static const Color warning = Color(0xFFFF9800);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFFE65100);
  
  /// Info colors
  static const Color info = Color(0xFF2196F3);
  static const Color infoContainer = Color(0xFFE3F2FD);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onInfoContainer = Color(0xFF0D47A1);
  
  // ============================================================================
  // Status Colors (상태 색상)
  // ============================================================================
  
  /// Order status colors
  static const Color pending = Color(0xFFFF9800);      // 대기중
  static const Color approved = Color(0xFF4CAF50);     // 승인됨
  static const Color rejected = Color(0xFFF44336);     // 거절됨
  static const Color completed = Color(0xFF2196F3);    // 완료됨
  static const Color cancelled = Color(0xFF9E9E9E);    // 취소됨
  
  /// Connection status colors
  static const Color connected = Color(0xFF4CAF50);    // 연결됨
  static const Color disconnected = Color(0xFF9E9E9E); // 연결 해제
  static const Color requesting = Color(0xFFFF9800);   // 요청중
  
  // ============================================================================
  // Gradient Colors (그라데이션 색상)
  // ============================================================================
  
  /// Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [lightPrimary, Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Secondary gradient
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [lightSecondary, Color(0xFF455A64)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Warning gradient
  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ============================================================================
  // Utility Methods (유틸리티 메서드)
  // ============================================================================
  
  /// 주문 상태에 따른 색상 반환
  static Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pending;
      case 'approved':
        return approved;
      case 'rejected':
        return rejected;
      case 'completed':
        return completed;
      case 'cancelled':
        return cancelled;
      default:
        return lightOnSurfaceVariant;
    }
  }
  
  /// 연결 상태에 따른 색상 반환
  static Color getConnectionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
        return connected;
      case 'disconnected':
        return disconnected;
      case 'requesting':
        return requesting;
      default:
        return lightOnSurfaceVariant;
    }
  }
  
  /// 우선순위에 따른 색상 반환
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return lightError;
      case 'medium':
        return warning;
      case 'low':
        return info;
      default:
        return lightOnSurfaceVariant;
    }
  }
  
  /// 색상에 투명도 적용
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// 색상 밝기 조정
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  /// 색상 어둡게 조정
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  /// 테마에 따른 색상 반환
  static Color getColorForTheme(BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return Theme.of(context).brightness == Brightness.light
        ? lightColor
        : darkColor;
  }
  
  /// 대비되는 텍스트 색상 반환
  static Color getContrastingTextColor(Color backgroundColor) {
    // 색상의 밝기를 계산하여 대비되는 텍스트 색상 반환
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
  
  // ============================================================================
  // Color Schemes (색상 스킴)
  // ============================================================================
  
  /// Light ColorScheme
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: lightPrimary,
    onPrimary: lightOnPrimary,
    primaryContainer: lightPrimaryContainer,
    onPrimaryContainer: lightOnPrimaryContainer,
    secondary: lightSecondary,
    onSecondary: lightOnSecondary,
    secondaryContainer: lightSecondaryContainer,
    onSecondaryContainer: lightOnSecondaryContainer,
    tertiary: lightTertiary,
    onTertiary: lightOnTertiary,
    tertiaryContainer: lightTertiaryContainer,
    onTertiaryContainer: lightOnTertiaryContainer,
    error: lightError,
    onError: lightOnError,
    errorContainer: lightErrorContainer,
    onErrorContainer: lightOnErrorContainer,
    background: lightBackground,
    onBackground: lightOnBackground,
    surface: lightSurface,
    onSurface: lightOnSurface,
    surfaceVariant: lightSurfaceVariant,
    onSurfaceVariant: lightOnSurfaceVariant,
    outline: lightOutline,
    outlineVariant: lightOutlineVariant,
  );
  
  /// Dark ColorScheme
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    secondary: darkSecondary,
    onSecondary: darkOnSecondary,
    secondaryContainer: darkSecondaryContainer,
    onSecondaryContainer: darkOnSecondaryContainer,
    tertiary: darkTertiary,
    onTertiary: darkOnTertiary,
    tertiaryContainer: darkTertiaryContainer,
    onTertiaryContainer: darkOnTertiaryContainer,
    error: darkError,
    onError: darkOnError,
    errorContainer: darkErrorContainer,
    onErrorContainer: darkOnErrorContainer,
    background: darkBackground,
    onBackground: darkOnBackground,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceVariant: darkSurfaceVariant,
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
  );
}
