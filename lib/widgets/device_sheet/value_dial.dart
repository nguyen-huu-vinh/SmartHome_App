import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';

/// Icon + giá trị lớn + thước kéo (độ sáng, nhiệt độ, góc xoay...).
class DialRow extends StatelessWidget {
  const DialRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.dial,
  });

  final IconData icon;
  final Color iconColor;
  final ValueDial dial;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Icon(icon, color: iconColor, size: 30),
        // Màn hẹp → chữ tự thu nhỏ thay vì tràn.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(dial.format(dial.value), style: AppText.bold(28)),
          ),
        ),
        Expanded(child: dial),
      ],
    );
  }
}

/// Thước vạch kéo ngang: kéo phải → tăng, trái → giảm;
/// mỗi [stepPx] px = 1 nấc (rung nhẹ mỗi nấc). Giá trị nằm trong [min]–[max].
class ValueDial extends StatefulWidget {
  const ValueDial({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.format,
    required this.stepPx,
    required this.onStep,
  });

  /// Tên giá trị cho trình đọc màn hình, VD: "Brightness".
  final String label;
  final int value, min, max;

  /// Cách hiện giá trị, VD: `(v) => '$v%'`.
  final String Function(int value) format;
  final double stepPx;

  /// Nhận +1 / -1 mỗi nấc (nơi gọi tự giới hạn giá trị).
  final ValueChanged<int> onStep;

  @override
  State<ValueDial> createState() => _ValueDialState();
}

class _ValueDialState extends State<ValueDial> {
  static const _gap = 12.0; // khoảng cách giữa các vạch
  double _drag = 0;

  void _onDrag(DragUpdateDetails e) {
    _drag += e.delta.dx;
    while (_drag.abs() >= widget.stepPx) {
      HapticFeedback.selectionClick();
      widget.onStep(_drag.sign.toInt());
      _drag -= _drag.sign * widget.stepPx;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    String preview(int d) => w.format((w.value + d).clamp(w.min, w.max));
    return Semantics(
      slider: true,
      label: w.label,
      value: preview(0),
      increasedValue: preview(1),
      decreasedValue: preview(-1),
      onIncrease: () => w.onStep(1),
      onDecrease: () => w.onStep(-1),
      child: LayoutBuilder(
        builder: (_, box) {
          // Số vạch lẻ để có vạch giữa; vừa với bề ngang.
          var n = (box.maxWidth / _gap).floor();
          if (n.isEven) n--;
          final mid = n ~/ 2;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: _onDrag,
            onHorizontalDragEnd: (_) => _drag = 0,
            child: SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [for (var i = 0; i < n; i++) _tick((i - mid).abs())],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Vạch giữa xanh cao nhất, càng xa càng thấp, ngoài cùng là chấm xám.
  Widget _tick(int d) {
    final (h, c) = switch (d) {
      0 => (24.0, AppColors.brand),
      1 => (20.0, AppColors.dark),
      2 => (18.0, AppColors.dark),
      3 => (10.0, AppColors.dark),
      _ => (6.0, AppColors.grey),
    };
    return Container(
      width: 4,
      height: h,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
