import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/room.dart';
import 'pressable.dart';

// Các nhãn / huy hiệu nhỏ dùng lặp lại ở nhiều màn.

/// "● Connected" / "● Online" màu xanh lá; [active] = false → xám.
class StatusDot extends StatelessWidget {
  const StatusDot(this.label, {super.key, this.active = true});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = active ? AppColors.success : AppColors.grey;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        CircleAvatar(radius: 4, backgroundColor: c),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(size: 16, color: c),
          ),
        ),
      ],
    );
  }
}

/// Icon nhỏ + chữ, VD: "⚡ 220V - Today".
class IconLabel extends StatelessWidget {
  const IconLabel({
    super.key,
    required this.text,
    this.icon = Icons.bolt_rounded,
    this.color = AppColors.amber,
  });

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Icon(icon, size: 20, color: color),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(size: 16),
          ),
        ),
      ],
    );
  }
}

/// "23%" nền tối + tia sét khi đang sạc.
class BatteryBadge extends StatelessWidget {
  const BatteryBadge({super.key, required this.level, required this.charging});

  final int level;
  final bool charging;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Battery $level%${charging ? ', charging' : ''}',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '$level%',
                style: AppText.bold(11, color: Colors.white),
              ),
            ),
            if (charging)
              const Icon(Icons.bolt_rounded, size: 16, color: AppColors.amber),
          ],
        ),
      ),
    );
  }
}

/// Ô vuông màu của phòng, icon trắng. [glow] → quầng màu bên dưới.
class RoomBadge extends StatelessWidget {
  const RoomBadge({
    super.key,
    required this.room,
    this.size = 44,
    this.glow = false,
  });

  final Room room;
  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.27;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: room.color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: glow ? AppShadows.glow(room.color, blur: radius) : null,
      ),
      child: Icon(room.icon, color: Colors.white, size: size * 0.545),
    );
  }
}

/// Nút tròn đỏ "−" để xoá. Vùng bấm rộng hơn hình vẽ [hitPadding] mỗi phía.
class RemoveBadge extends StatelessWidget {
  const RemoveBadge({
    super.key,
    required this.label,
    required this.onTap,
    this.size = 20,
    this.hitPadding = 8,
  });

  /// Đọc cho trình đọc màn hình, VD: "Remove Kitchen".
  final String label;
  final VoidCallback onTap;
  final double size, hitPadding;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      ripple: false,
      scale: 0.85,
      semanticLabel: label,
      padding: EdgeInsets.all(hitPadding),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.danger,
        child: Icon(Icons.remove, size: size * 0.7, color: Colors.white),
      ),
    );
  }
}

/// Vòng xám "+" (đi kèm chữ "Add ...").
class AddBadge extends StatelessWidget {
  const AddBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 10,
      backgroundColor: AppColors.muted,
      child: Icon(Icons.add, size: 14, color: AppColors.dark),
    );
  }
}

/// Số đếm nhỏ màu đỏ gắn góc icon (VD: số thông báo). [count] = 0 → ẩn.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      backgroundColor: AppColors.danger,
      label: Text(count > 9 ? '9+' : '$count'),
      textStyle: AppText.bold(10, color: Colors.white),
      child: child,
    );
  }
}
