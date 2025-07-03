import 'package:flutter/material.dart';

/// 🎨 앱에서 사용하는 모든 색상 (8개만)
/// 색상을 바꾸고 싶을 때 이 파일에서 수정하세요!
class AppColors {
  // 🔵 메인 색상 (2개)
  static const Color primary = Color(0xFF2196F3);      // 파란색 - 버튼, 선택된 아이템
  static const Color primaryDark = Color(0xFF1976D2);  // 진한 파란색 - 호버, 강조
  
  // ⚪ 배경 색상 (3개)
  static const Color background = Color(0xFFF5F5F5);   // 연한 회색 - 앱 배경
  static const Color surface = Color(0xFFFFFFFF);      // 흰색 - 카드, 다이얼로그
  static const Color error = Color(0xFFB00020);        // 빨간색 - 에러 메시지
  
  // 📝 텍스트 색상 (3개)
  static const Color textPrimary = Color(0xFF212121);   // 진한 회색 - 메인 텍스트
  static const Color textSecondary = Color(0xFF757575); // 중간 회색 - 보조 텍스트
  static const Color textHint = Color(0xFFBDBDBD);      // 연한 회색 - 힌트, 비활성 텍스트
  
  // 🚫 사용하지 않는 색상들 (참고용)
  // static const Color secondaryColor = Color(0xFF03DAC6);  // 제거됨
  // static const LinearGradient primaryGradient = ...;      // 제거됨
}
