import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'pressable.dart';

/// Thẻ trắng bo góc, viền mảnh, bóng mờ — khung chung của mọi thẻ trong app.
/// [onTap] → bấm được (lún nhẹ + gợn sóng). [selected] true → viền
/// [selectedColor]; null = thẻ không có trạng thái chọn.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.width,
    this.height,
    this.radius = AppSizes.radiusM,
    this.shadow = AppShadows.card,
    this.color = Colors.white,
    this.selected,
    this.selectedColor = AppColors.dark,
    this.selectedWidth = 1,
    this.clip = false,
    this.haptic = false,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? width, height;
  final double radius;
  final List<BoxShadow>? shadow;
  final Color color;
  final bool? selected;
  final Color selectedColor;
  final double selectedWidth;

  /// Cắt phần con tràn ra ngoài góc bo (VD: quầng sáng).
  final bool clip;
  final bool haptic;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    final on = selected ?? false;
    return SizedBox(
      width: width,
      height: height,
      child: Pressable(
        onTap: onTap,
        haptic: haptic,
        semanticLabel: semanticLabel,
        selected: selected,
        borderRadius: r,
        padding: padding,
        clipBehavior: clip ? Clip.antiAlias : Clip.none,
        decoration: BoxDecoration(
          color: color,
          borderRadius: r,
          border: Border.all(
            color: on ? selectedColor : AppColors.line,
            width: on ? selectedWidth : 1,
          ),
          boxShadow: shadow,
        ),
        child: child,
      ),
    );
  }
}
