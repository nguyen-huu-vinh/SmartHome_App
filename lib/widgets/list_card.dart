import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/device.dart';
import 'app_card.dart';
import 'app_image.dart';

/// Thẻ danh sách chung: ảnh 48, tiêu đề, dòng phụ, phần đuôi tuỳ chọn.
/// [selected] → viền tối (dùng khi chọn).
class ListCard extends StatelessWidget {
  const ListCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.subtitleColor = AppColors.dark,
    this.trailing,
    this.selected,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final Widget? trailing;
  final bool? selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      shadow: null,
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 16,
        children: [
          SizedBox.square(dimension: 48, child: leading),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(title, style: AppText.body(size: 16)),
                AnimatedSwitcher(
                  duration: AppMotion.medium,
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [...previous, ?current],
                  ),
                  child: Text(
                    subtitle,
                    key: ValueKey(subtitle),
                    style: AppText.body(color: subtitleColor),
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Thẻ thiết bị: [ListCard] với ảnh thiết bị và trạng thái kết nối.
class DeviceTile extends StatelessWidget {
  const DeviceTile({
    super.key,
    required this.device,
    required this.status,
    this.statusColor = AppColors.dark,
    this.trailing,
    this.selected,
    this.onTap,
  });

  final Device device;
  final String status;
  final Color statusColor;
  final Widget? trailing;
  final bool? selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      // Ảnh tạm cắt từ thiết kế còn dính viền tròn ở góc → cắt tròn.
      leading: ClipOval(child: AppImage(device.image)),
      title: device.name,
      subtitle: status,
      subtitleColor: statusColor,
      trailing: trailing,
      selected: selected,
      onTap: onTap,
    );
  }
}
