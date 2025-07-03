## 📁 Theme 관련 코드 구조
### **파일 구조**
/theme/
  ├── app_colors.dart (색상 8개만 - 찾기 쉽게)
  └── app_theme.dart (ThemeData + Google Fonts)


## 🎨 app_colors.dart - 모든 색상을 한눈에

dart
import 'package:flutter/material.dart';

class AppColors {
  // 🔵 메인 색상 (2개)
  static const Color primary = Color(0xFF2196F3);      // 파란색
  static const Color primaryDark = Color(0xFF1976D2);  // 진한 파란색
  
  // ⚪ 배경 색상 (3개)
  static const Color background = Color(0xFFF5F5F5);   // 연한 회색 배경
  static const Color surface = Color(0xFFFFFFFF);      // 흰색 카드/표면
  static const Color error = Color(0xFFB00020);        // 빨간색 에러
  
  // 📝 텍스트 색상 (3개)
  static const Color textPrimary = Color(0xFF212121);   // 진한 회색 (메인 텍스트)
  static const Color textSecondary = Color(0xFF757575); // 중간 회색 (보조 텍스트)
  static const Color textHint = Color(0xFFBDBDBD);      // 연한 회색 (힌트/비활성)
}


## 🎯 app_theme.dart - 테마 설정

dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // 📏 간격 (4개만)
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xlarge = 32.0;
  
  // 📱 테마 데이터
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // 🎨 색상 설정 (찾기 쉽게)
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),
      
      // 📝 폰트 설정 (Google Fonts)
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // 큰 제목
        headlineLarge: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        // 중간 제목  
        headlineMedium: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        // 작은 제목
        titleLarge: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        // 본문 텍스트
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: AppColors.textPrimary),
        // 작은 텍스트
        bodySmall: GoogleFonts.inter(
          fontSize: 12, color: AppColors.textSecondary),
      ),
      
      // 🃏 카드 테마
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      
      // 🔘 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}


## 🔧 수정하기 쉬운 포인트들

### **색상 바꾸고 싶을 때:**
dart
// app_colors.dart에서 한 줄만 수정
static const Color primary = Color(0xFF4CAF50); // 파란색 → 초록색


### **폰트 크기 바꾸고 싶을 때:**
dart
// app_theme.dart에서 해당 라인만 수정
fontSize: 18, // 제목 크기 변경


### **간격 바꾸고 싶을 때:**
dart
// app_theme.dart 상단에서
static const double medium = 20.0; // 16 → 20으로 변경


## 💡 사용법 (코드에서)

dart
// 색상 사용
Container(color: AppColors.primary)
Text('제목', style: TextStyle(color: AppColors.textPrimary))

// 간격 사용  
SizedBox(height: AppTheme.medium)
Padding(padding: EdgeInsets.all(AppTheme.large))


이렇게 하면 색상이나 폰트를 바꾸고 싶을 때 정확히 어느 파일의 어느 줄을 수정해야 하는지 바로 알 수 있습니다! 🎯