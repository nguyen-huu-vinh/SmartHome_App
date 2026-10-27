import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/assets.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/device_settings.dart';
import '../../data/home_device.dart';
import '../app_image.dart';
import '../app_sheet.dart';
import '../badges.dart';
import '../device_controls.dart';
import '../layout.dart';
import '../pressable.dart';
import 'value_dial.dart';

/// Bảng chi tiết máy hút bụi: thời gian dọn (vòng xoay), nguồn,
/// thời gian nghỉ giữa các lượt và hẹn giờ theo buổi.
class CleanerSheet extends StatelessWidget {
  const CleanerSheet({super.key, required this.device});

  final HomeDevice device;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = app.cleaner(device);
    final on = app.isOn(device);
    void edit(void Function(CleanerSettings s) f) => app.update(() => f(s));
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetHeader(
              title: device.name,
              status: Row(
                spacing: 8,
                children: [
                  const Flexible(child: StatusDot('Connected')),
                  BatteryBadge(level: s.battery, charging: s.charging),
                ],
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (_, box) {
                final dial = math.min(150.0, box.maxWidth * 0.46);
                return Row(
                  children: [
                    // Ảnh tràn sát mép trái như thiết kế.
                    Expanded(
                      child: Transform.translate(
                        offset: const Offset(-16, 0),
                        child: AppImage(
                          AppImages.cleanerHero,
                          height: dial + 84,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                    Column(
                      spacing: 20,
                      children: [
                        Dimmed(
                          enabled: on,
                          child: _TimerDial(
                            size: dial,
                            minutes: s.minutes,
                            onChanged: (v) => edit((s) => s.setMinutes(v)),
                          ),
                        ),
                        PowerBox(
                          on: on,
                          onChanged: (v) => app.setOn(device, v),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            Dimmed(
              enabled: on,
              child: _BreakRow(
                seconds: s.breakSec,
                onStep: (d) => edit((s) => s.setBreak(s.breakSec + d)),
              ),
            ),
            const SizedBox(height: 20),
            // Hẹn giờ vẫn chỉnh được khi máy đang tắt.
            _ScheduleCard(
              enabled: s.scheduled,
              time: s.time,
              onToggle: (v) => edit((s) => s.scheduled = v),
              onTime: (t) => edit((s) => s.time = t),
            ),
          ],
        ),
      ),
    );
  }
}

/// "↻ Break  ||||  45 Sec": kéo thước để đổi thời gian nghỉ giữa các lượt.
class _BreakRow extends StatelessWidget {
  const _BreakRow({required this.seconds, required this.onStep});

  final int seconds;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    // Màn hẹp → chữ tự thu nhỏ thay vì tràn.
    Widget fit(String text, double size, double maxWidth) => ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, style: AppText.semibold(size)),
      ),
    );
    return LayoutBuilder(
      builder: (_, box) => Row(
        spacing: 12,
        children: [
          const Icon(
            Icons.restart_alt_rounded,
            size: 28,
            color: AppColors.dark,
          ),
          fit('Break', 20, box.maxWidth * 0.25),
          Expanded(
            child: ValueDial(
              label: 'Break between rounds',
              value: seconds,
              min: CleanerSettings.minBreak,
              max: CleanerSettings.maxBreak,
              format: (v) => '$v seconds',
              stepPx: 6, // 6px kéo = 1 giây
              onStep: onStep,
            ),
          ),
          fit('$seconds Sec', 18, box.maxWidth * 0.25),
        ],
      ),
    );
  }
}

/// Vòng chọn thời gian dọn: kéo nút tròn quanh vòng (bắt đầu từ đáy,
/// theo chiều kim đồng hồ). Giữa vòng là số phút.
class _TimerDial extends StatelessWidget {
  const _TimerDial({
    required this.size,
    required this.minutes,
    required this.onChanged,
  });

  final double size;
  final int minutes;
  final ValueChanged<int> onChanged;

  static const _max = CleanerSettings.maxMinutes;

  void _set(int v) {
    if (v == minutes) return;
    HapticFeedback.selectionClick();
    onChanged(v);
  }

  void _drag(Offset p) {
    final c = size / 2;
    // Góc tính từ đáy, chiều kim đồng hồ, 0–1.
    final a = math.atan2(p.dy - c, p.dx - c) - math.pi / 2;
    final t = (a % (2 * math.pi)) / (2 * math.pi);
    var v = (t * _max).round();
    // Không cho nhảy vòng qua điểm đầu/cuối.
    if (minutes > _max * 0.8 && v < _max * 0.2) v = _max;
    if (minutes < _max * 0.2 && v > _max * 0.8) v = 1;
    _set(v.clamp(1, _max));
  }

  @override
  Widget build(BuildContext context) {
    final ring = size * 0.17;
    return Semantics(
      slider: true,
      label: 'Cleaning time',
      value: '$minutes minutes',
      increasedValue: '${math.min(minutes + 1, _max)} minutes',
      decreasedValue: '${math.max(minutes - 1, 1)} minutes',
      onIncrease: () => onChanged(math.min(minutes + 1, _max)),
      onDecrease: () => onChanged(math.max(minutes - 1, 1)),
      child: GestureDetector(
        onPanDown: (e) => _drag(e.localPosition),
        onPanUpdate: (e) => _drag(e.localPosition),
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _DialPainter(progress: minutes / _max, ring: ring),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(ring + 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$minutes', style: AppText.bold(32, height: 1.1)),
                      Text(
                        'Minutes',
                        style: AppText.body(color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({required this.progress, required this.ring});

  final double progress, ring;

  static const _color = Color(0xFF5B7CFF);
  static const _lines = 200;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final outer = size.width / 2 - 2;
    final inner = outer - ring;
    final paint = Paint()
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    // Vòng vạch mảnh: phần đã chọn đậm, phần còn lại nhạt.
    for (var i = 0; i < _lines; i++) {
      final t = i / _lines;
      final a = math.pi / 2 + t * 2 * math.pi;
      final dir = Offset(math.cos(a), math.sin(a));
      paint.color = _color.withValues(alpha: t <= progress ? 0.85 : 0.18);
      canvas.drawLine(c + dir * inner, c + dir * outer, paint);
    }

    // Nền trắng giữa vòng.
    canvas.drawCircle(
      c,
      inner - 2,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2),
    );

    // Nút kéo ở cuối phần đã chọn.
    final a = math.pi / 2 + progress * 2 * math.pi;
    final knob = c + Offset(math.cos(a), math.sin(a)) * (inner + ring / 2);
    final r = ring * 0.62;
    canvas.drawCircle(
      knob + const Offset(0, 1),
      r + 1,
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(knob, r, Paint()..color = Colors.white);
    canvas.drawCircle(
      knob,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = _color.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.progress != progress || old.ring != ring;
}

/// Thẻ "Schedule To": công tắc bật hẹn giờ + chọn buổi.
class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.enabled,
    required this.time,
    required this.onToggle,
    required this.onTime,
  });

  final bool enabled;
  final CleanTime time;
  final ValueChanged<bool> onToggle;
  final ValueChanged<CleanTime> onTime;

  static (IconData, Color) _icon(CleanTime t) => switch (t) {
    CleanTime.morning => (Icons.wb_twilight_rounded, AppColors.grey),
    CleanTime.noon => (Icons.wb_sunny_rounded, const Color(0xFFE0A526)),
    CleanTime.evening => (Icons.wb_twilight_rounded, const Color(0xFFE8B84A)),
    CleanTime.night => (Icons.nights_stay_rounded, AppColors.brand),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Schedule To',
                  style: AppText.body(size: 16, color: AppColors.grey),
                ),
              ),
              Switch(value: enabled, onChanged: onToggle),
            ],
          ),
          const SizedBox(height: 8),
          Dimmed(
            enabled: enabled,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Row(
                spacing: 4,
                children: [
                  for (final t in CleanTime.values)
                    Expanded(child: _segment(t, t == time)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment(CleanTime t, bool selected) {
    final (icon, color) = _icon(t);
    final radius = BorderRadius.circular(14);
    return Pressable(
      onTap: () => onTime(t),
      haptic: true,
      selected: selected,
      scale: 0.94,
      borderRadius: radius,
      decoration: BoxDecoration(
        color: selected ? AppColors.dark : Colors.white,
        borderRadius: radius,
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Column(
        spacing: 6,
        children: [
          Icon(icon, size: 26, color: selected ? Colors.white : color),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              t.label,
              maxLines: 1,
              style: AppText.body(
                size: 16,
                color: selected ? Colors.white : AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
