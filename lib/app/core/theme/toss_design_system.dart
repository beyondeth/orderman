import 'package:flutter/material.dart';

/// 토스 스타일 디자인 시스템
class TossDesignSystem {
  // 토스 컬러 팔레트
  static const Color primary = Color(0xFF0064FF);
  static const Color primaryLight = Color(0xFF4285FF);
  static const Color primaryDark = Color(0xFF0052CC);

  static const Color secondary = Color(0xFF00D9FF);
  static const Color accent = Color(0xFFFF6B6B);

  // 그레이 스케일 (토스 스타일)
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // 시맨틱 컬러
  static const Color success = Color(0xFF7986CB);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF42A5F5);
  // static const Color delivery = Color(0xFF7986CB);

  // 배경색
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F9FA);

  // 텍스트 컬러
  static const Color textPrimary = Color(0xFF191F28);
  static const Color textSecondary = Color(0xFF8B95A1);
  static const Color textTertiary = Color(0xFFB0B8C1);

  // 토스 타이포그래피
  static const String fontFamily = 'Pretendard';

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
    color: textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
    color: textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static const TextStyle heading4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
    color: textPrimary,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.1,
  );

  // 토스 스타일 간격
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // 토스 스타일 반지름
  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;

  // 토스 스타일 그림자
  static const List<BoxShadow> shadow1 = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadow3 = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  // 토스 스타일 버튼
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius12),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spacing20,
      vertical: spacing16,
    ),
    textStyle: button,
  );

  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: gray100,
    foregroundColor: textPrimary,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius12),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spacing20,
      vertical: spacing16,
    ),
    textStyle: button,
  );

  static ButtonStyle outlineButton = OutlinedButton.styleFrom(
    foregroundColor: primary,
    side: const BorderSide(color: gray300, width: 1),
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius12),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spacing20,
      vertical: spacing16,
    ),
    textStyle: button,
  );

  // 토스 스타일 카드
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius16),
    boxShadow: shadow2,
  );

  static BoxDecoration surfaceDecoration = BoxDecoration(
    color: surfaceVariant,
    borderRadius: BorderRadius.circular(radius12),
  );

  // 토스 스타일 입력 필드
  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius12),
        borderSide: const BorderSide(color: gray300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius12),
        borderSide: const BorderSide(color: gray300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
      labelStyle: body2.copyWith(color: textSecondary),
      hintStyle: body2.copyWith(color: textTertiary),
    );
  }
}

/// 토스 스타일 위젯들
class TossWidgets {
  /// 토스 스타일 카드
  static Widget card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: TossDesignSystem.cardDecoration,
        padding: padding ?? const EdgeInsets.all(TossDesignSystem.spacing20),
        child: child,
      ),
    );
  }

  /// 토스 스타일 표면 카드
  static Widget surfaceCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: TossDesignSystem.surfaceDecoration,
        padding: padding ?? const EdgeInsets.all(TossDesignSystem.spacing16),
        child: child,
      ),
    );
  }

  /// 토스 스타일 뱃지
  static Widget badge({
    required String text,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossDesignSystem.spacing8,
        vertical: TossDesignSystem.spacing4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? TossDesignSystem.gray100,
        borderRadius: BorderRadius.circular(TossDesignSystem.radius8),
      ),
      child: Text(
        text,
        style: TossDesignSystem.caption.copyWith(
          color: textColor ?? TossDesignSystem.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 토스 스타일 상태 뱃지
  static Widget statusBadge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossDesignSystem.spacing8,
        vertical: TossDesignSystem.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TossDesignSystem.radius8),
      ),
      child: Text(
        text,
        style: TossDesignSystem.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 토스 스타일 아이콘 버튼
  static Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
    double? size,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size ?? 40,
        height: size ?? 40,
        decoration: BoxDecoration(
          color: backgroundColor ?? TossDesignSystem.gray100,
          borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
        ),
        child: Icon(
          icon,
          color: iconColor ?? TossDesignSystem.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}
