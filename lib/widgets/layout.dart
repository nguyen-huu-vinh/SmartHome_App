import 'package:flutter/material.dart';

import '../core/theme.dart';

// Khối bố cục dùng lặp lại: tiêu đề mục, danh sách ngang, trạng thái rỗng,
// vùng bị khoá.

/// Tiêu đề mục + phần bên phải (VD: "Lights & Decoration ... View all").
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppText.heading)),
        ?trailing,
      ],
    );
  }
}

/// Danh sách cuộn ngang cao [height]. Thẻ tràn ra mép màn hình như thiết kế
/// (không cắt bóng / viền của thẻ).
class HorizontalList extends StatelessWidget {
  const HorizontalList({
    super.key,
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
    this.spacing = 16,
    this.controller,
  });

  final double height;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        controller: controller,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(width: spacing),
        itemBuilder: itemBuilder,
      ),
    );
  }
}

/// Không có gì để hiện: icon xám + câu giải thích.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.padding = const EdgeInsets.all(32),
  });

  final IconData icon;
  final String message;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Icon(icon, size: 48, color: AppColors.disabled),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.body(size: 16, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

/// [enabled] = false → mờ đi và không bấm được (VD: thiết bị đang tắt).
class Dimmed extends StatelessWidget {
  const Dimmed({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: AnimatedOpacity(
        duration: AppMotion.fast,
        opacity: enabled ? 1 : 0.4,
        child: child,
      ),
    );
  }
}
