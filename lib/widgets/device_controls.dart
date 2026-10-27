import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import 'pressable.dart';

// Các kiểu công tắc nguồn của thiết bị. Cùng 1 quy ước:
// [on] = trạng thái hiện tại, [onChanged] nhận trạng thái mới.

void _toggle(ValueChanged<bool> onChanged, bool value) {
  HapticFeedback.lightImpact();
  onChanged(value);
}

/// Nút nguồn "ON ⏻" có viền; tắt → "OFF" xám. Dùng trong bảng chi tiết.
class PowerBox extends StatelessWidget {
  const PowerBox({super.key, required this.on, required this.onChanged});

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Semantics(
      toggled: on,
      label: 'Power',
      child: Pressable(
        onTap: () => _toggle(onChanged, !on),
        scale: 0.94,
        borderRadius: radius,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: on ? AppColors.dark : AppColors.line,
            width: on ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 14,
          children: [
            Text(
              on ? 'ON' : 'OFF',
              style: AppText.body(
                size: 16,
                color: on ? AppColors.dark : AppColors.grey,
              ),
            ),
            AnimatedContainer(
              duration: AppMotion.fast,
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: on ? AppColors.dark : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.power_settings_new_rounded,
                color: on ? Colors.white : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "⏻ ON" nền brand — nút nguồn của thẻ nổi bật ở Home.
class PowerPill extends StatelessWidget {
  const PowerPill({super.key, required this.on, required this.onChanged});

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.radiusS);
    return Semantics(
      toggled: on,
      label: 'Power',
      child: Pressable(
        onTap: () => _toggle(onChanged, !on),
        scale: 0.94,
        borderRadius: radius,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: radius,
        ),
        padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            AnimatedContainer(
              duration: AppMotion.fast,
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: on ? AppColors.brand : AppColors.soft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.power_settings_new_rounded,
                color: on ? Colors.white : AppColors.grey,
              ),
            ),
            Text(
              on ? 'ON' : 'OFF',
              style: AppText.body(color: on ? AppColors.dark : AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Công tắc gạt nhỏ: bật → nền brand, tắt → nền xám.
class PowerSwitch extends StatelessWidget {
  const PowerSwitch({super.key, required this.on, required this.onChanged});

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: on,
      label: 'Power',
      child: Pressable(
        onTap: () => _toggle(onChanged, !on),
        ripple: false,
        scale: 0.9,
        // Vùng bấm rộng hơn công tắc (thẻ thấp nên chỉ nới chiều ngang).
        padding: const EdgeInsets.only(left: 12),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.curve,
          width: 44,
          height: 24,
          padding: const EdgeInsets.all(3),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: on ? AppColors.brand : AppColors.soft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CircleAvatar(
            radius: 9,
            backgroundColor: on ? Colors.white : AppColors.knob,
          ),
        ),
      ),
    );
  }
}

/// Công tắc dọc OFF / ON của thẻ đèn.
class VerticalSwitch extends StatelessWidget {
  const VerticalSwitch({super.key, required this.on, required this.onChanged});

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget half(String label, bool value) {
      final active = on == value;
      // ON đang bật → nền tối; OFF đang tắt → nền xám.
      final bg = !active
          ? Colors.transparent
          : value
          ? AppColors.dark
          : AppColors.soft;
      final radius = BorderRadius.circular(8);
      return Pressable(
        // Bấm nửa đang chọn: không đổi gì (và không lọt xuống thẻ bên dưới).
        onTap: () {
          if (!active) _toggle(onChanged, value);
        },
        semanticLabel: value ? 'Turn on' : 'Turn off',
        scale: 0.92,
        borderRadius: radius,
        decoration: BoxDecoration(color: bg, borderRadius: radius),
        child: SizedBox(
          width: 40,
          height: 30,
          child: Center(
            child: Text(
              label,
              style: AppText.body(
                color: active && value ? Colors.white : AppColors.dark,
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      toggled: on,
      label: 'Power',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Column(
          spacing: 4,
          children: [half('OFF', false), half('ON', true)],
        ),
      ),
    );
  }
}
