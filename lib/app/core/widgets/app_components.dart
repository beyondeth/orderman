import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import 'package:get/get.dart';

/// 앱 전체에서 사용할 일관된 컴포넌트들
/// Material Design 3 기반으로 구현
class AppComponents {
  /// Primary Button (FilledButton 기반)
  static Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
    EdgeInsetsGeometry? padding,
  }) {
    Widget buttonChild =
        isLoading
            ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  onPressed != null ? Colors.white : Colors.grey,
                ),
              ),
            )
            : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  AppSpacing.horizontalGapSM,
                ],
                Text(text, style: AppTypography.buttonText),
              ],
            );

    Widget button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        padding:
            padding ??
            AppSpacing.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
      ),
      child: buttonChild,
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  /// Secondary Button (OutlinedButton 기반)
  static Widget secondaryButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
    EdgeInsetsGeometry? padding,
  }) {
    Widget buttonChild =
        isLoading
            ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  onPressed != null
                      ? Theme.of(Get.context!).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            )
            : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  AppSpacing.horizontalGapSM,
                ],
                Text(text, style: AppTypography.buttonText),
              ],
            );

    Widget button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding:
            padding ??
            AppSpacing.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
      ),
      child: buttonChild,
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  /// Outlined Button
  static Widget outlinedButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isEnabled = true,
    EdgeInsets? padding,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: OutlinedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: OutlinedButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
  static Widget textButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    EdgeInsetsGeometry? padding,
  }) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        padding:
            padding ??
            AppSpacing.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
      ),
      child:
          isLoading
              ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    onPressed != null
                        ? Theme.of(Get.context!).colorScheme.primary
                        : Colors.grey,
                  ),
                ),
              )
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    AppSpacing.horizontalGapSM,
                  ],
                  Text(text, style: AppTypography.buttonText),
                ],
              ),
    );
  }

  /// App Card
  static Widget appCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    Color? backgroundColor,
    double? elevation,
    BorderRadius? borderRadius,
  }) {
    Widget cardWidget = Card(
      elevation: elevation ?? 1,
      color: backgroundColor,
      margin: margin ?? AppSpacing.paddingSM,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.md),
      ),
      child: Padding(padding: padding ?? AppSpacing.paddingMD, child: child),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.md),
        child: cardWidget,
      );
    }

    return cardWidget;
  }

  /// Section Header
  static Widget sectionHeader({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: AppSpacing.verticalSM,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headlineSmall),
                if (subtitle != null) ...[
                  AppSpacing.verticalGapXS,
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
          if (onTap != null)
            IconButton(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
        ],
      ),
    );
  }

  /// Loading Indicator
  static Widget loadingIndicator({String? message, double? size}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: size ?? 40,
            width: size ?? 40,
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...[
            AppSpacing.verticalGapMD,
            Text(
              message,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Empty State
  static Widget emptyState({
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 64, color: Colors.grey[400]),
              AppSpacing.verticalGapLG,
            ],
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              AppSpacing.verticalGapSM,
              Text(
                subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[AppSpacing.verticalGapLG, action],
          ],
        ),
      ),
    );
  }

  /// Status Chip
  static Widget statusChip({
    required String label,
    required Color color,
    Color? textColor,
    IconData? icon,
  }) {
    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor ?? color),
            AppSpacing.horizontalGapXS,
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: textColor ?? color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Input Field
  static Widget inputField({
    required String label,
    String? hint,
    String? initialValue,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    int? maxLines,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.titleSmall),
        AppSpacing.verticalGapXS,
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          validator: validator,
          onChanged: onChanged,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }

  /// List Tile
  static Widget listTile({
    Widget? leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return ListTile(
      leading: leading,
      title: Text(title, style: AppTypography.titleMedium),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
              )
              : null,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      enabled: enabled,
    );
  }

  /// Divider
  static Widget divider({
    double? height,
    double? thickness,
    Color? color,
    double? indent,
    double? endIndent,
  }) {
    return Divider(
      height: height ?? AppSpacing.md,
      thickness: thickness ?? 1,
      color: color,
      indent: indent,
      endIndent: endIndent,
    );
  }

  /// App Bar
  static PreferredSizeWidget appBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
  }) {
    return AppBar(
      title: Text(title, style: AppTypography.appBarTitle),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation ?? 0,
    );
  }
}
