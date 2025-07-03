import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // 임시 비활성화

/// Material Design 3 Typography System
/// 일관된 텍스트 스타일을 제공하는 Typography 클래스
class AppTypography {
  // Base font family - 시스템 폰트 사용
  static String get fontFamily => 'Roboto'; // 기본 Material 폰트
  
  // Material Design 3 Typography Scale
  // https://m3.material.io/styles/typography/type-scale-tokens
  
  /// Display styles - 가장 큰 텍스트, 짧은 중요한 텍스트용
  static TextStyle get displayLarge => const TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );
  
  static TextStyle get displayMedium => const TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );
  
  static TextStyle get displaySmall => const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );
  
  /// Headline styles - 중간 크기 텍스트, 짧은 고강조 텍스트용
  static TextStyle get headlineLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.25,
  );
  
  static TextStyle get headlineMedium => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.29,
  );
  
  static TextStyle get headlineSmall => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
  );
  
  /// Title styles - 중간 강조 텍스트용
  static TextStyle get titleLarge => const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );
  
  static TextStyle get titleMedium => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.50,
  );
  
  static TextStyle get titleSmall => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  /// Label styles - 버튼, 탭 등의 라벨용
  static TextStyle get labelLarge => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  static TextStyle get labelMedium => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );
  
  static TextStyle get labelSmall => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );
  
  /// Body styles - 본문 텍스트용
  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
  );
  
  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );
  
  static TextStyle get bodySmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );
  
  /// 앱 특화 스타일들
  /// 자주 사용되는 스타일들을 미리 정의
  
  /// 앱바 타이틀용
  static TextStyle get appBarTitle => titleLarge.copyWith(
    fontWeight: FontWeight.w600,
  );
  
  /// 카드 타이틀용
  static TextStyle get cardTitle => titleMedium.copyWith(
    fontWeight: FontWeight.w600,
  );
  
  /// 버튼 텍스트용
  static TextStyle get buttonText => labelLarge.copyWith(
    fontWeight: FontWeight.w600,
  );
  
  /// 캡션/설명 텍스트용
  static TextStyle get caption => bodySmall.copyWith(
    color: Colors.black54,
  );
  
  /// 에러 텍스트용
  static TextStyle get error => bodySmall.copyWith(
    color: Colors.red,
    fontWeight: FontWeight.w500,
  );
  
  /// 성공 텍스트용
  static TextStyle get success => bodySmall.copyWith(
    color: Colors.green,
    fontWeight: FontWeight.w500,
  );
  
  /// 가격 표시용 (강조)
  static TextStyle get price => titleMedium.copyWith(
    fontWeight: FontWeight.w700,
    color: Colors.blue,
  );
  
  /// 상태 표시용
  static TextStyle get status => labelMedium.copyWith(
    fontWeight: FontWeight.w600,
  );
  
  /// 텍스트 스케일링을 고려한 스타일 생성
  /// 접근성을 위해 텍스트 크기 제한
  static TextStyle scaleAwareStyle(TextStyle style, BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final clampedScaleFactor = textScaleFactor.clamp(0.8, 1.4);
    
    return style.copyWith(
      fontSize: style.fontSize! * clampedScaleFactor,
    );
  }
  
  /// 다크 테마용 색상 적용
  static TextStyle applyDarkTheme(TextStyle style) {
    return style.copyWith(
      color: _getDarkThemeColor(style.color),
    );
  }
  
  static Color? _getDarkThemeColor(Color? lightColor) {
    if (lightColor == null) return null;
    
    // 기본 색상 매핑
    if (lightColor == Colors.black87) return Colors.white;
    if (lightColor == Colors.black54) return Colors.white70;
    if (lightColor == Colors.black38) return Colors.white38;
    
    return lightColor;
  }
  
  /// 전체 TextTheme 생성 (Light)
  static TextTheme get lightTextTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
  );
  
  /// 전체 TextTheme 생성 (Dark)
  static TextTheme get darkTextTheme => TextTheme(
    displayLarge: applyDarkTheme(displayLarge),
    displayMedium: applyDarkTheme(displayMedium),
    displaySmall: applyDarkTheme(displaySmall),
    headlineLarge: applyDarkTheme(headlineLarge),
    headlineMedium: applyDarkTheme(headlineMedium),
    headlineSmall: applyDarkTheme(headlineSmall),
    titleLarge: applyDarkTheme(titleLarge),
    titleMedium: applyDarkTheme(titleMedium),
    titleSmall: applyDarkTheme(titleSmall),
    labelLarge: applyDarkTheme(labelLarge),
    labelMedium: applyDarkTheme(labelMedium),
    labelSmall: applyDarkTheme(labelSmall),
    bodyLarge: applyDarkTheme(bodyLarge),
    bodyMedium: applyDarkTheme(bodyMedium),
    bodySmall: applyDarkTheme(bodySmall),
  );
}

/// Typography 사용 예시를 위한 확장
extension TextStyleExtensions on TextStyle {
  /// 색상 변경
  TextStyle withColor(Color color) => copyWith(color: color);
  
  /// 굵기 변경
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);
  
  /// 크기 변경
  TextStyle withSize(double size) => copyWith(fontSize: size);
  
  /// 투명도 적용
  TextStyle withOpacity(double opacity) => copyWith(
    color: color?.withOpacity(opacity),
  );
}
