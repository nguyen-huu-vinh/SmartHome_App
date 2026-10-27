import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/device_settings.dart';
import '../app_image.dart';
import 'stat_card.dart';

// Phần riêng của đèn trong bảng chi tiết: ảnh đèn đổi màu theo cài đặt,
// thanh nhiệt độ màu, số liệu.

/// Dải màu từ vàng ấm → trắng xanh, dùng cho thanh trượt và quầng sáng.
const _warmCool = [
  Color(0xFFF9A31B),
  Color(0xFFFCC93A),
  Color(0xFF8FC3A8),
  AppColors.brand,
  Color(0xFF1F4BFF),
];

Color _sample(double t) {
  final x = t.clamp(0.0, 1.0) * (_warmCool.length - 1);
  final i = x.floor().clamp(0, _warmCool.length - 2);
  return Color.lerp(_warmCool[i], _warmCool[i + 1], x - i)!;
}

/// Ma trận xoay sắc độ: giữ nguyên màu trung tính (thân đèn bạc, chao trắng),
/// chỉ đổi màu quầng sáng.
List<double> _hueRotate(double degrees) {
  final r = degrees * math.pi / 180;
  final c = math.cos(r), s = math.sin(r);
  const lr = 0.213, lg = 0.715, lb = 0.072;
  return [
    lr + c * (1 - lr) - s * lr,
    lg - c * lg - s * lg,
    lb - c * lb + s * (1 - lb),
    0,
    0, //
    lr - c * lr + s * 0.143,
    lg + c * (1 - lg) + s * 0.140,
    lb - c * lb - s * 0.283,
    0,
    0,
    lr - c * lr - s * (1 - lr),
    lg - c * lg + s * lg,
    lb + c * (1 - lb) + s * lb,
    0,
    0,
    0, 0, 0, 1, 0,
  ];
}

const _greyscale = <double>[
  0.213, 0.715, 0.072, 0, 0, //
  0.213, 0.715, 0.072, 0, 0,
  0.213, 0.715, 0.072, 0, 0,
  0, 0, 0, 1, 0,
];

/// Ảnh đèn: lớp xám bên dưới (đèn tắt), lớp màu bên trên mờ theo độ sáng;
/// quầng sáng đổi màu theo nhiệt độ màu.
class LampImage extends StatelessWidget {
  const LampImage({
    super.key,
    required this.image,
    required this.on,
    required this.light,
  });

  final String image;
  final bool on;
  final LightSettings light;

  @override
  Widget build(BuildContext context) {
    final glow = on ? (0.5 + 0.5 * light.brightness / 100) : 0.0;
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.matrix(_greyscale),
            child: AppImage(image),
          ),
          AnimatedOpacity(
            duration: AppMotion.medium,
            opacity: glow,
            child: ColorFiltered(
              // Ảnh gốc quầng vàng (~35°) → xoay tới xanh (~210°).
              colorFilter: ColorFilter.matrix(_hueRotate(light.warmth * 175)),
              child: AppImage(image),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thanh nhiệt độ màu + chú thích Warm/Cool + số liệu (giờ chạy, AQI).
/// Đổi cài đặt qua [update] (để màn khác cùng thấy thay đổi).
class LightPanel extends StatelessWidget {
  const LightPanel({super.key, required this.light, required this.update});

  final LightSettings light;
  final void Function(VoidCallback change) update;

  @override
  Widget build(BuildContext context) {
    Widget legend(String label, Color dot) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        CircleAvatar(radius: 5, backgroundColor: dot),
        Text(label, style: AppText.body(size: 16)),
      ],
    );
    return Column(
      children: [
        _WarmthSlider(
          value: light.warmth,
          onChanged: (v) => update(() => light.warmth = v),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              legend('Warm', const Color(0xFFD69E1E)),
              legend('Cool', AppColors.brand),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          spacing: 16,
          children: [
            Expanded(
              child: StatCard(
                icon: const Icon(Icons.alarm_rounded, color: Colors.white),
                color: AppColors.brand,
                value: '${light.runHours.toString().padLeft(2, '0')} Hr',
                label: 'Run time',
              ),
            ),
            Expanded(
              child: StatCard(
                icon: const Icon(Icons.eco_rounded, color: Colors.white),
                color: const Color(0xFFDDB24F),
                value: '${light.aqi} AQI',
                label: light.aqiLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Thanh trượt nhiệt độ màu: kéo hoặc chạm để chọn.
class _WarmthSlider extends StatelessWidget {
  const _WarmthSlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  static const _height = 32.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, box) {
        final w = box.maxWidth;
        // Nút trượt nằm gọn trong thanh: tâm chạy từ h/2 tới w - h/2.
        void set(double dx) =>
            onChanged(((dx - _height / 2) / (w - _height)).clamp(0.0, 1.0));
        final x = value * (w - _height);
        // Trình đọc màn hình: tăng/giảm mỗi lần 10%.
        double step(double d) => (value + d).clamp(0.0, 1.0);
        String describe(double v) => '${(v * 100).round()}% cool';
        return Semantics(
          slider: true,
          label: 'Color temperature',
          value: describe(value),
          increasedValue: describe(step(0.1)),
          decreasedValue: describe(step(-0.1)),
          onIncrease: () => onChanged(step(0.1)),
          onDecrease: () => onChanged(step(-0.1)),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (e) => set(e.localPosition.dx),
            onHorizontalDragUpdate: (e) => set(e.localPosition.dx),
            child: SizedBox(
              height: _height + 12,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: _height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_height / 2),
                      gradient: const LinearGradient(colors: _warmCool),
                      boxShadow: [
                        BoxShadow(
                          color: _sample(value).withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: x,
                    child: Container(
                      width: _height,
                      height: _height,
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          // Màu nhạt của điểm đang chọn.
                          color: Color.lerp(_sample(value), Colors.white, 0.55),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
