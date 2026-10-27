import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../data/device_settings.dart';
import '../app_image.dart';
import '../pressable.dart';

// Phần riêng của máy lạnh trong bảng chi tiết: ảnh có quầng xanh, nhãn
// Remote, bàn phím điều khiển.

/// Ảnh thiết bị, có quầng xanh bên dưới khi đang chạy.
class GlowImage extends StatelessWidget {
  const GlowImage({super.key, required this.image, required this.on});

  final String image;
  final bool on;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              duration: AppMotion.medium,
              opacity: on ? 1 : 0,
              child: Container(
                height: 70,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.4,
                    colors: [Color(0x553DB4FF), Color(0x003DB4FF)],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: AppImage(image),
          ),
        ],
      ),
    );
  }
}

/// "● Remote": xanh lá khi máy đang chạy, xám khi tắt.
class RemoteBadge extends StatelessWidget {
  const RemoteBadge({super.key, required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final c = on ? AppColors.success : AppColors.grey;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: c.withValues(alpha: 0.12),
          child: CircleAvatar(radius: 5, backgroundColor: c),
        ),
        Text('Remote', style: AppText.body(size: 16)),
      ],
    );
  }
}

/// Bàn phím điều khiển 3 cột như remote. Đổi cài đặt qua [update].
class AcRemote extends StatelessWidget {
  const AcRemote({super.key, required this.ac, required this.update});

  final AcSettings ac;
  final void Function(VoidCallback change) update;

  @override
  Widget build(BuildContext context) {
    void edit(void Function(AcSettings a) f) {
      HapticFeedback.selectionClick();
      update(() => f(ac));
    }

    Widget row(Widget left, Widget mid, Widget right) => Row(
      spacing: 16,
      children: [
        Expanded(child: left),
        mid,
        Expanded(child: right),
      ],
    );
    return Column(
      spacing: 16,
      children: [
        row(
          _PadButton(
            label: 'Mode',
            value: ac.mode.label,
            onTap: () => edit((a) => a.mode = a.mode.next),
          ),
          _RoundButton(
            icon: Icons.arrow_drop_up_rounded,
            tooltip: 'Temperature up',
            onTap: () => edit((a) => a.setTemp(a.temp + 1)),
          ),
          _PadButton(
            label: 'Fan Speed',
            value: ac.fan.label,
            onTap: () => edit((a) => a.fan = a.fan.next),
          ),
        ),
        row(
          _PadButton(
            label: 'Swing',
            semanticLabel: 'Swing left',
            leading: Icons.arrow_left_rounded,
            stadium: true,
            active: ac.swingLeft,
            onTap: () => edit((a) => a.swingLeft = !a.swingLeft),
          ),
          _RoundButton(
            icon: Icons.sync_rounded,
            tooltip: 'Auto swing',
            active: ac.autoSwing,
            onTap: () => edit((a) => a.autoSwing = !a.autoSwing),
          ),
          _PadButton(
            label: 'Swing',
            semanticLabel: 'Swing right',
            trailing: Icons.arrow_right_rounded,
            stadium: true,
            active: ac.swingRight,
            onTap: () => edit((a) => a.swingRight = !a.swingRight),
          ),
        ),
        row(
          _PadButton(
            label: 'Energy Ctrl',
            active: ac.energySaving,
            onTap: () => edit((a) => a.energySaving = !a.energySaving),
          ),
          _RoundButton(
            icon: Icons.arrow_drop_down_rounded,
            tooltip: 'Temperature down',
            onTap: () => edit((a) => a.setTemp(a.temp - 1)),
          ),
          _PadButton(
            label: 'High Cooling',
            active: ac.highCooling,
            onTap: () => edit((a) => a.highCooling = !a.highCooling),
          ),
        ),
      ],
    );
  }
}

/// Nút chữ của remote. [value] hiện nhỏ bên dưới (VD: chế độ đang chọn).
/// [active] → nền tối, chữ trắng. [stadium] → bo tròn 2 đầu.
class _PadButton extends StatelessWidget {
  const _PadButton({
    required this.label,
    required this.onTap,
    this.semanticLabel,
    this.value,
    this.leading,
    this.trailing,
    this.active = false,
    this.stadium = false,
  });

  final String label;
  final String? semanticLabel;
  final String? value;
  final IconData? leading, trailing;
  final bool active, stadium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : AppColors.dark;
    final radius = BorderRadius.circular(stadium ? 26 : 10);
    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      // Nút bật/tắt (Swing, Energy...) báo trạng thái cho trình đọc màn hình.
      selected: value == null ? active : null,
      scale: 0.95,
      borderRadius: radius,
      decoration: BoxDecoration(
        color: active ? AppColors.dark : AppColors.surface,
        borderRadius: radius,
      ),
      // Cao tối thiểu theo thiết kế; chữ hệ thống to hơn thì nút cao theo.
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: stadium ? 52 : 46),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) Icon(leading, color: fg, size: 30),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(size: 16, color: fg),
                  ),
                  if (value case final v?)
                    Text(
                      v,
                      maxLines: 1,
                      style: AppText.body(
                        size: 11,
                        color: active ? Colors.white70 : AppColors.grey,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) Icon(trailing, color: fg, size: 30),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        scale: 0.92,
        borderRadius: BorderRadius.circular(26),
        decoration: BoxDecoration(
          color: active ? AppColors.dark : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
        ),
        child: SizedBox.square(
          dimension: 50,
          child: Icon(
            icon,
            size: 30,
            color: active ? Colors.white : AppColors.dark,
          ),
        ),
      ),
    );
  }
}
