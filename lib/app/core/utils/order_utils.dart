import 'package:flutter/material.dart';

class OrderUtils {
  /// 금액을 포맷팅합니다 (예: 1000 -> "1,000원")
  static String formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  /// 날짜를 상대적 시간으로 포맷팅합니다 (예: "2일 전", "오늘")
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else if (difference < 7) {
      return '${difference}일 전';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '${weeks}주 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
