import 'package:flutter/material.dart';

import '../core/feedback.dart';
import '../core/theme.dart';
import '../data/room.dart';
import 'app_card.dart';
import 'badges.dart';

/// Ô chọn phòng: icon màu + tên. [selected] → viền [selectedColor].
class RoomCard extends StatelessWidget {
  const RoomCard({
    super.key,
    required this.room,
    required this.selected,
    required this.onTap,
    this.selectedColor = AppColors.brand,
  });

  static const width = 116.0;

  final Room room;
  final bool selected;
  final VoidCallback onTap;

  /// Màu viền khi được chọn (VD: màu của phòng).
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: width,
      radius: AppSizes.radiusS,
      padding: const EdgeInsets.all(12),
      selected: selected,
      selectedColor: selectedColor,
      haptic: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(room.icon, color: room.color, size: 24),
          Text(
            room.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(size: 16),
          ),
        ],
      ),
    );
  }
}

/// Ô lọc theo phòng ở Home: icon nền màu + tên + số thiết bị.
/// [selected] → viền brand.
class RoomChip extends StatelessWidget {
  const RoomChip({
    super.key,
    required this.room,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final Room room;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: 150,
      padding: const EdgeInsets.all(6),
      shadow: AppShadows.raised,
      selected: selected,
      selectedColor: AppColors.brand,
      haptic: true,
      onTap: onTap,
      child: Row(
        spacing: 12,
        children: [
          RoomBadge(room: room),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.name,
                ),
                Text(
                  plural(count, 'Device'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
