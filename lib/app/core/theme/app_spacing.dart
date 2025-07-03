import 'package:flutter/material.dart';

/// 앱 전체에서 사용할 일관된 스페이싱 시스템
/// Material Design 3 spacing guidelines 기반
class AppSpacing {
  // Base spacing unit (8dp)
  static const double _baseUnit = 8.0;
  
  /// 기본 스페이싱 값들
  static const double none = 0.0;
  static const double xs = _baseUnit * 0.5;  // 4dp
  static const double sm = _baseUnit;        // 8dp
  static const double md = _baseUnit * 2;    // 16dp
  static const double lg = _baseUnit * 3;    // 24dp
  static const double xl = _baseUnit * 4;    // 32dp
  static const double xxl = _baseUnit * 6;   // 48dp
  static const double xxxl = _baseUnit * 8;  // 64dp
  
  /// 특수 목적 스페이싱
  static const double cardPadding = md;      // 카드 내부 패딩
  static const double screenPadding = md;    // 화면 가장자리 패딩
  static const double sectionSpacing = lg;   // 섹션 간 간격
  static const double itemSpacing = sm;      // 아이템 간 간격
  static const double buttonPadding = md;    // 버튼 내부 패딩
  
  /// EdgeInsets 헬퍼들
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  
  /// 수평 패딩
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);
  
  /// 수직 패딩
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);
  
  /// 화면별 특화 패딩
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: screenPadding);
  static const EdgeInsets screenVertical = EdgeInsets.symmetric(vertical: screenPadding);
  static const EdgeInsets screenAll = EdgeInsets.all(screenPadding);
  
  /// 카드 패딩
  static const EdgeInsets cardHorizontal = EdgeInsets.symmetric(horizontal: cardPadding);
  static const EdgeInsets cardVertical = EdgeInsets.symmetric(vertical: cardPadding);
  static const EdgeInsets cardAll = EdgeInsets.all(cardPadding);
  
  /// SizedBox 헬퍼들
  static const SizedBox gapXS = SizedBox(height: xs, width: xs);
  static const SizedBox gapSM = SizedBox(height: sm, width: sm);
  static const SizedBox gapMD = SizedBox(height: md, width: md);
  static const SizedBox gapLG = SizedBox(height: lg, width: lg);
  static const SizedBox gapXL = SizedBox(height: xl, width: xl);
  
  /// 수직 간격
  static const SizedBox verticalGapXS = SizedBox(height: xs);
  static const SizedBox verticalGapSM = SizedBox(height: sm);
  static const SizedBox verticalGapMD = SizedBox(height: md);
  static const SizedBox verticalGapLG = SizedBox(height: lg);
  static const SizedBox verticalGapXL = SizedBox(height: xl);
  static const SizedBox verticalGapXXL = SizedBox(height: xxl);
  
  /// 수평 간격
  static const SizedBox horizontalGapXS = SizedBox(width: xs);
  static const SizedBox horizontalGapSM = SizedBox(width: sm);
  static const SizedBox horizontalGapMD = SizedBox(width: md);
  static const SizedBox horizontalGapLG = SizedBox(width: lg);
  static const SizedBox horizontalGapXL = SizedBox(width: xl);
  
  /// 동적 스페이싱 생성
  static EdgeInsets symmetric({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal ?? 0,
      vertical: vertical ?? 0,
    );
  }
  
  static EdgeInsets only({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left ?? 0,
      top: top ?? 0,
      right: right ?? 0,
      bottom: bottom ?? 0,
    );
  }
  
  static SizedBox gap(double size) => SizedBox(height: size, width: size);
  static SizedBox verticalGap(double height) => SizedBox(height: height);
  static SizedBox horizontalGap(double width) => SizedBox(width: width);
  
  /// 반응형 스페이싱
  /// 화면 크기에 따라 스페이싱 조정
  static double responsive(BuildContext context, {
    double mobile = md,
    double tablet = lg,
    double desktop = xl,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= 1200) {
      return desktop;
    } else if (screenWidth >= 600) {
      return tablet;
    } else {
      return mobile;
    }
  }
  
  static EdgeInsets responsivePadding(BuildContext context, {
    EdgeInsets mobile = paddingMD,
    EdgeInsets tablet = paddingLG,
    EdgeInsets desktop = paddingXL,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= 1200) {
      return desktop;
    } else if (screenWidth >= 600) {
      return tablet;
    } else {
      return mobile;
    }
  }
}

/// 스페이싱 확장 메서드
extension SpacingExtensions on num {
  /// 숫자를 SizedBox로 변환
  SizedBox get verticalSpace => SizedBox(height: toDouble());
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
  SizedBox get space => SizedBox(height: toDouble(), width: toDouble());
  
  /// 숫자를 EdgeInsets로 변환
  EdgeInsets get padding => EdgeInsets.all(toDouble());
  EdgeInsets get horizontalPadding => EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: toDouble());
}

/// 위젯 확장 메서드
extension WidgetSpacingExtensions on Widget {
  /// 위젯에 패딩 추가
  Widget paddingAll(double padding) => Padding(
    padding: EdgeInsets.all(padding),
    child: this,
  );
  
  Widget paddingSymmetric({double? horizontal, double? vertical}) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: horizontal ?? 0,
      vertical: vertical ?? 0,
    ),
    child: this,
  );
  
  Widget paddingOnly({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) => Padding(
    padding: EdgeInsets.only(
      left: left ?? 0,
      top: top ?? 0,
      right: right ?? 0,
      bottom: bottom ?? 0,
    ),
    child: this,
  );
  
  /// 미리 정의된 패딩 적용
  Widget get paddingXS => paddingAll(AppSpacing.xs);
  Widget get paddingSM => paddingAll(AppSpacing.sm);
  Widget get paddingMD => paddingAll(AppSpacing.md);
  Widget get paddingLG => paddingAll(AppSpacing.lg);
  Widget get paddingXL => paddingAll(AppSpacing.xl);
  
  /// 화면 패딩 적용
  Widget get screenPadding => paddingAll(AppSpacing.screenPadding);
  Widget get cardPadding => paddingAll(AppSpacing.cardPadding);
}
