import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// Material Design 3 NavigationBar를 사용하는 공통 네비게이션 컴포넌트
class AppNavigation {
  /// Bottom Navigation Bar (Material 3 NavigationBar)
  static Widget bottomNavigationBar({
    required int currentIndex,
    required Function(int) onDestinationSelected,
    required List<NavigationDestination> destinations,
    Color? backgroundColor,
    Color? indicatorColor,
    double? height,
  }) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
      height: height ?? 80,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    );
  }

  /// Navigation Destination 생성 헬퍼
  static NavigationDestination destination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    String? tooltip,
  }) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      label: label,
      tooltip: tooltip,
    );
  }

  /// 구매자용 네비게이션 목적지들
  static List<NavigationDestination> get buyerDestinations => [
    destination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: '홈',
      tooltip: '홈 화면',
    ),
    destination(
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      label: '주문',
      tooltip: '주문 화면',
    ),
    destination(
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      label: '내역',
      tooltip: '주문 내역',
    ),
    destination(
      icon: Icons.link_outlined,
      selectedIcon: Icons.link,
      label: '연결',
      tooltip: '판매자 연결',
    ),
  ];

  /// 판매자용 네비게이션 목적지들
  static List<NavigationDestination> get sellerDestinations => [
    destination(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: '홈',
      tooltip: '홈',
    ),
    destination(
      icon: Icons.inventory_outlined,
      selectedIcon: Icons.inventory,
      label: '상품',
      tooltip: '상품 관리',
    ),
    destination(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: '주문',
      tooltip: '주문 관리',
    ),
    destination(
      icon: Icons.people_outlined,
      selectedIcon: Icons.people,
      label: '고객',
      tooltip: '고객 관리',
    ),
  ];

  /// Navigation Rail (태블릿/데스크톱용)
  static Widget navigationRail({
    required int selectedIndex,
    required Function(int) onDestinationSelected,
    required List<NavigationRailDestination> destinations,
    bool extended = false,
    Widget? leading,
    Widget? trailing,
  }) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      extended: extended,
      leading: leading,
      trailing: trailing,
      labelType:
          extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
    );
  }

  /// Navigation Rail Destination 생성 헬퍼
  static NavigationRailDestination railDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    String? tooltip,
  }) {
    return NavigationRailDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      label: Text(label, style: AppTypography.labelMedium),
    );
  }

  /// Drawer (사이드 메뉴)
  static Widget drawer({
    Widget? header,
    required List<Widget> children,
    Color? backgroundColor,
  }) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          if (header != null) header,
          Expanded(
            child: ListView(padding: EdgeInsets.zero, children: children),
          ),
        ],
      ),
    );
  }

  /// Drawer Header
  static Widget drawerHeader({
    required String title,
    String? subtitle,
    Widget? avatar,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        title,
        style: AppTypography.titleLarge.copyWith(color: Colors.white),
      ),
      accountEmail:
          subtitle != null
              ? Text(
                subtitle,
                style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
              )
              : null,
      currentAccountPicture: avatar,
      decoration: BoxDecoration(color: backgroundColor),
      onDetailsPressed: onTap,
    );
  }

  /// Drawer Item
  static Widget drawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool selected = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: selected ? null : Colors.grey[600]),
      title: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: selected ? null : Colors.grey[800],
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
              )
              : null,
      onTap: onTap,
      selected: selected,
      contentPadding: AppSpacing.horizontalMD,
    );
  }

  /// Tab Bar
  static Widget tabBar({
    required TabController controller,
    required List<Tab> tabs,
    bool isScrollable = false,
    Color? indicatorColor,
    Color? labelColor,
    Color? unselectedLabelColor,
  }) {
    return TabBar(
      controller: controller,
      tabs: tabs,
      isScrollable: isScrollable,
      indicatorColor: indicatorColor,
      labelColor: labelColor,
      unselectedLabelColor: unselectedLabelColor,
      labelStyle: AppTypography.titleSmall,
      unselectedLabelStyle: AppTypography.titleSmall,
      padding: AppSpacing.horizontalSM,
      indicatorPadding: AppSpacing.horizontalSM,
    );
  }

  /// Tab
  static Tab tab({required String text, IconData? icon}) {
    return Tab(text: text, icon: icon != null ? Icon(icon, size: 20) : null);
  }

  /// Breadcrumb (경로 표시)
  static Widget breadcrumb({
    required List<String> items,
    Function(int)? onTap,
    String separator = ' > ',
  }) {
    return Wrap(
      children:
          items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onTap != null ? () => onTap(index) : null,
                  child: Text(
                    item,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isLast ? null : Colors.blue,
                      decoration:
                          isLast || onTap == null
                              ? null
                              : TextDecoration.underline,
                    ),
                  ),
                ),
                if (!isLast)
                  Text(
                    separator,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            );
          }).toList(),
    );
  }

  /// Floating Action Button
  static Widget floatingActionButton({
    required VoidCallback onPressed,
    required Widget child,
    String? tooltip,
    Color? backgroundColor,
    Color? foregroundColor,
    bool mini = false,
    FloatingActionButtonLocation? location,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      mini: mini,
      child: child,
    );
  }

  /// Extended Floating Action Button
  static Widget extendedFloatingActionButton({
    required VoidCallback onPressed,
    required String label,
    IconData? icon,
    String? tooltip,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: Text(label, style: AppTypography.labelLarge),
      icon: icon != null ? Icon(icon) : null,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}
