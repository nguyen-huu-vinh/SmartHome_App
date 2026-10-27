import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../app_card.dart';

/// Ô số liệu: icon nền màu + giá trị + nhãn (VD: "04 Hr / Run time").
/// Có [onTap] → bấm để đổi (VD: chất lượng hình).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.onTap,
  });

  final Widget icon;
  final Color color;
  final String value, label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(8),
      onTap: onTap,
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: icon,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(size: 16),
                ),
                Text(
                  label,
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
