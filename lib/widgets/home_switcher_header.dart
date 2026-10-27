import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'headers.dart';
import 'pressable.dart';

/// Đầu trang "Welcome Back" + tên nhà, bấm để chọn nhà khác.
/// Có [onTap] → màn gọi tự xử lý (VD: mở bảng quản lý nhà);
/// không có → menu chọn nhà đơn giản, chọn xong gọi [onChanged].
class HomeSwitcherHeader extends StatelessWidget {
  const HomeSwitcherHeader({
    super.key,
    required this.homes,
    required this.index,
    this.onChanged,
    this.onTap,
  });

  final List<String> homes;
  final int index;
  final ValueChanged<int>? onChanged;
  final VoidCallback? onTap;

  Widget _name() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: Text(
          homes[index],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.semibold(20),
        ),
      ),
      const Icon(Icons.arrow_drop_down, color: AppColors.dark),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    return GradientHeader(
      child: Column(
        spacing: 4,
        children: [
          Text('Welcome Back', style: AppText.body()),
          if (onTap != null)
            Pressable(
              onTap: onTap,
              ripple: false,
              semanticLabel: 'Change home',
              child: _name(),
            )
          else
            PopupMenuButton<int>(
              tooltip: 'Change home',
              initialValue: index,
              onSelected: onChanged,
              position: PopupMenuPosition.under,
              itemBuilder: (_) => [
                for (var i = 0; i < homes.length; i++)
                  PopupMenuItem(value: i, child: Text(homes[i])),
              ],
              child: _name(),
            ),
        ],
      ),
    );
  }
}
