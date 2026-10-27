import 'package:flutter/material.dart';

import '../core/theme.dart';

// Icon tự vẽ / ghép tạm, thay bằng SVG khi có asset.

/// Khối lập phương 3 mặt. Mặc định màu xanh; [CubeIcon.grey] cho thanh điều hướng.
class CubeIcon extends StatelessWidget {
  const CubeIcon({
    super.key,
    this.size = 20,
    this.top = const Color(0xFFBFE6FF),
    this.left = const Color(0xFF1677C9),
    this.right = const Color(0xFF6EC4FF),
  });

  const CubeIcon.grey({super.key, this.size = 22})
    : top = const Color(0xFFB9BBC3),
      left = AppColors.knob,
      right = AppColors.idle;

  final double size;
  final Color top, left, right;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _CubePainter(top, left, right),
  );
}

class _CubePainter extends CustomPainter {
  const _CubePainter(this.top, this.left, this.right);

  final Color top, left, right;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    Path face(List<Offset> pts) => Path()..addPolygon(pts, true);
    final t = Offset(s / 2, 0);
    final l = Offset(0, s * .25);
    final r = Offset(s, s * .25);
    final mid = Offset(s / 2, s * .5);
    final b = Offset(s / 2, s);
    canvas
      ..drawPath(face([t, r, mid, l]), Paint()..color = top)
      ..drawPath(face([l, mid, b, Offset(0, s * .75)]), Paint()..color = left)
      ..drawPath(face([mid, r, Offset(s, s * .75), b]), Paint()..color = right);
  }

  @override
  bool shouldRepaint(_CubePainter old) =>
      old.top != top || old.left != left || old.right != right;
}

/// Ngôi nhà có sóng wifi bên trong.
class HomeWifiIcon extends StatelessWidget {
  const HomeWifiIcon({
    super.key,
    this.size = 24,
    this.color = AppColors.muted,
    this.wifiColor = AppColors.dark,
  });

  final double size;
  final Color color, wifiColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: const Alignment(0, 0.4),
        children: [
          Icon(Icons.home_rounded, size: size, color: color),
          Icon(Icons.wifi, size: size * 0.46, color: wifiColor),
        ],
      ),
    );
  }
}
