import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// 반응형 레이아웃을 위한 브레이크포인트 정의
class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;
}

/// 화면 크기 타입
enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// 반응형 레이아웃 유틸리티
class AppLayout {
  /// 현재 화면 타입 반환
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= AppBreakpoints.largeDesktop) {
      return ScreenType.largeDesktop;
    } else if (width >= AppBreakpoints.desktop) {
      return ScreenType.desktop;
    } else if (width >= AppBreakpoints.tablet) {
      return ScreenType.tablet;
    } else {
      return ScreenType.mobile;
    }
  }
  
  /// 화면 타입별 값 반환
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.mobile:
        return mobile;
    }
  }
  
  /// 반응형 컬럼 수 계산
  static int getColumns(BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int largeDesktop = 4,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
  
  /// 반응형 최대 너비
  static double getMaxWidth(BuildContext context) {
    return responsive(
      context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1000,
      largeDesktop: 1200,
    );
  }
  
  /// 반응형 패딩
  static EdgeInsets getScreenPadding(BuildContext context) {
    return responsive(
      context,
      mobile: AppSpacing.paddingMD,
      tablet: AppSpacing.paddingLG,
      desktop: AppSpacing.paddingXL,
      largeDesktop: const EdgeInsets.all(AppSpacing.xxl),
    );
  }
  
  /// 반응형 카드 패�ding
  static EdgeInsets getCardPadding(BuildContext context) {
    return responsive(
      context,
      mobile: AppSpacing.paddingMD,
      tablet: AppSpacing.paddingLG,
      desktop: AppSpacing.paddingLG,
    );
  }
  
  /// 반응형 간격
  static double getSpacing(BuildContext context, {
    double mobile = AppSpacing.md,
    double tablet = AppSpacing.lg,
    double desktop = AppSpacing.xl,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  /// 모바일 여부 확인
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }
  
  /// 태블릿 이상 여부 확인
  static bool isTabletOrLarger(BuildContext context) {
    final screenType = getScreenType(context);
    return screenType != ScreenType.mobile;
  }
  
  /// 데스크톱 이상 여부 확인
  static bool isDesktopOrLarger(BuildContext context) {
    final screenType = getScreenType(context);
    return screenType == ScreenType.desktop || screenType == ScreenType.largeDesktop;
  }
}

/// 반응형 컨테이너 위젯
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final bool centerContent;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.centerContent = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? AppLayout.getScreenPadding(context);
    final effectiveMaxWidth = maxWidth ?? AppLayout.getMaxWidth(context);
    
    Widget content = Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
      padding: effectivePadding,
      child: child,
    );
    
    if (centerContent && effectiveMaxWidth != double.infinity) {
      content = Center(child: content);
    }
    
    return content;
  }
}

/// 반응형 그리드 위젯
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.largeDesktopColumns = 4,
    this.spacing = AppSpacing.md,
    this.runSpacing = AppSpacing.md,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    final columns = AppLayout.getColumns(
      context,
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 3,
      largeDesktop: largeDesktopColumns ?? 4,
    );
    
    return ResponsiveContainer(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
          
          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children.map((child) {
              return SizedBox(
                width: itemWidth,
                child: child,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

/// 반응형 행 위젯
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool wrapOnMobile;
  final double spacing;
  
  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.wrapOnMobile = true,
    this.spacing = AppSpacing.md,
  });
  
  @override
  Widget build(BuildContext context) {
    if (wrapOnMobile && AppLayout.isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .expand((child) => [child, AppSpacing.verticalGapMD])
            .take(children.length * 2 - 1)
            .toList(),
      );
    }
    
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children
          .expand((child) => [child, SizedBox(width: spacing)])
          .take(children.length * 2 - 1)
          .toList(),
    );
  }
}

/// 반응형 카드 위젯
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  
  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? AppLayout.getCardPadding(context);
    final effectiveElevation = elevation ?? (AppLayout.isMobile(context) ? 2.0 : 4.0);
    
    return Card(
      elevation: effectiveElevation,
      color: color,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );
  }
}

/// 반응형 섹션 위젯
class ResponsiveSection extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showDivider;
  
  const ResponsiveSection({
    super.key,
    this.title,
    required this.child,
    this.padding,
    this.margin,
    this.showDivider = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final spacing = AppLayout.getSpacing(context);
    
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacing * 0.5),
            if (showDivider) ...[
              const Divider(),
              SizedBox(height: spacing * 0.5),
            ],
          ],
          child,
        ],
      ),
    );
  }
}

/// 반응형 확장 메서드
extension ResponsiveExtensions on Widget {
  /// 반응형 컨테이너로 감싸기
  Widget responsive({
    EdgeInsets? padding,
    double? maxWidth,
    bool centerContent = true,
  }) {
    return ResponsiveContainer(
      padding: padding,
      maxWidth: maxWidth,
      centerContent: centerContent,
      child: this,
    );
  }
  
  /// 반응형 카드로 감싸기
  Widget responsiveCard({
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? elevation,
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return ResponsiveCard(
      padding: padding,
      margin: margin,
      elevation: elevation,
      color: color,
      borderRadius: borderRadius,
      child: this,
    );
  }
  
  /// 반응형 섹션으로 감싸기
  Widget responsiveSection({
    String? title,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool showDivider = false,
  }) {
    return ResponsiveSection(
      title: title,
      padding: padding,
      margin: margin,
      showDivider: showDivider,
      child: this,
    );
  }
}
