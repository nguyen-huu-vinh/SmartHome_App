import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'badges.dart';
import 'pressable.dart';

/// Khung viền nét đứt bo góc (Flutter không có sẵn). Có [onTap] → bấm được.
class DashedBox extends StatelessWidget {
  const DashedBox({
    super.key,
    required this.child,
    this.height = 48,
    this.radius = AppSizes.radiusS,
    this.color = AppColors.border,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final double height, radius;
  final Color color;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashPainter(color, radius),
      child: Pressable(
        onTap: onTap,
        semanticLabel: semanticLabel,
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color, this.radius);
  final Color color;
  final double radius;

  static const _dash = 8.0, _gap = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final rect = (Offset.zero & size).deflate(0.5);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += _dash + _gap) {
        canvas.drawPath(m.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) =>
      old.color != color || old.radius != radius;
}

/// Ô viền đứt "⊕ [label]" để thêm mục mới (VD: Add Home).
class AddTile extends StatelessWidget {
  const AddTile({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 48,
    this.radius = AppSizes.radiusS,
  });

  final String label;
  final VoidCallback onTap;
  final double height, radius;

  @override
  Widget build(BuildContext context) {
    return DashedBox(
      height: height,
      radius: radius,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          const AddBadge(),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.medium(16),
            ),
          ),
        ],
      ),
    );
  }
}
