import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 🎯 심플한 앱 테마 설정
/// 폰트 크기나 간격을 바꾸고 싶을 때 이 파일에서 수정하세요!
class AppTheme {
  // 📏 간격 설정 (4개만) - 수정하기 쉽게
  static const double small = 8.0;    // 작은 간격
  static const double medium = 16.0;  // 보통 간격  
  static const double large = 24.0;   // 큰 간격
  static const double xlarge = 32.0;  // 매우 큰 간격
  
  // 📱 라이트 테마
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // 🎨 색상 설정 (AppColors에서 가져옴)
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
      
      // 📝 텍스트 스타일 (Google Fonts Inter 사용)
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // 🔤 큰 제목 (24px, 굵게)
        headlineLarge: GoogleFonts.inter(
          fontSize: 24, 
          fontWeight: FontWeight.bold, 
          color: AppColors.textPrimary,
        ),
        
        // 🔤 중간 제목 (20px, 세미볼드)
        headlineMedium: GoogleFonts.inter(
          fontSize: 20, 
          fontWeight: FontWeight.w600, 
          color: AppColors.textPrimary,
        ),
        
        // 🔤 작은 제목 (18px, 세미볼드)
        titleLarge: GoogleFonts.inter(
          fontSize: 18, 
          fontWeight: FontWeight.w600, 
          color: AppColors.textPrimary,
        ),
        
        // 🔤 중간 제목 (16px, 미디움)
        titleMedium: GoogleFonts.inter(
          fontSize: 16, 
          fontWeight: FontWeight.w500, 
          color: AppColors.textPrimary,
        ),
        
        // 🔤 큰 본문 (16px, 보통)
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, 
          fontWeight: FontWeight.w400, 
          color: AppColors.textPrimary,
        ),
        
        // 🔤 보통 본문 (14px, 보통)
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, 
          fontWeight: FontWeight.w400, 
          color: AppColors.textPrimary,
        ),
        
        // 🔤 작은 텍스트 (12px, 보조 색상)
        bodySmall: GoogleFonts.inter(
          fontSize: 12, 
          fontWeight: FontWeight.w400, 
          color: AppColors.textSecondary,
        ),
        
        // 🔤 라벨 (14px, 미디움)
        labelLarge: GoogleFonts.inter(
          fontSize: 14, 
          fontWeight: FontWeight.w500, 
          color: AppColors.textPrimary,
        ),
      ),
      
      // 🃏 카드 테마
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // 📱 앱바 테마
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      
      // 🔘 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // 📝 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.textHint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textHint,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// 🎨 자주 사용하는 스타일들 (선택사항)
class AppStyles {
  // 카드 데코레이션
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0A000000),
        offset: Offset(0, 2),
        blurRadius: 8,
      ),
    ],
  );
}
