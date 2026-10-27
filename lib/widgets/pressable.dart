import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

/// Vùng bấm có phản hồi: lún nhẹ khi nhấn (+ gợn sóng nếu [ripple]).
/// Dùng cho mọi thẻ / nút tự vẽ để cảm giác bấm giống nhau trong cả app.
///
/// - [decoration] (nền, viền, bóng) vẽ dưới gợn sóng, đổi mượt khi thay đổi.
/// - [onTap] null → chỉ vẽ [decoration] + [child], không bấm được.
/// - Lồng nhau vẫn đúng: nhấn nút con thì thẻ cha không lún (dựa trên [InkWell]).
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    required this.child,
    this.decoration,
    this.borderRadius,
    this.padding,
    this.clipBehavior = Clip.none,
    this.scale = 0.97,
    this.ripple = true,
    this.haptic = false,
    this.semanticLabel,
    this.selected,
  });

  final VoidCallback? onTap;
  final Widget child;
  final BoxDecoration? decoration;

  /// Bo góc của vùng gợn sóng (nên khớp [decoration]).
  final BorderRadius? borderRadius;

  /// Lề trong (nằm trong vùng bấm).
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;

  /// Tỉ lệ thu nhỏ khi nhấn.
  final double scale;
  final bool ripple;

  /// Rung nhẹ khi bấm (chọn mục, đổi tab).
  final bool haptic;
  final String? semanticLabel;

  /// Đang được chọn (cho trình đọc màn hình); null = không phải ô chọn.
  final bool? selected;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
    reverseDuration: const Duration(milliseconds: 160),
  );
  late final _curve = CurvedAnimation(parent: _press, curve: Curves.easeOut);
  late final _scale = Tween(begin: 1.0, end: widget.scale).animate(_curve);
  var _down = false;

  @override
  void initState() {
    super.initState();
    // Chạm nhanh: lún hết rồi mới nảy lại, để vẫn thấy được phản hồi.
    _press.addStatusListener((s) {
      if (s == AnimationStatus.completed && !_down) _press.reverse();
    });
  }

  @override
  void dispose() {
    _curve.dispose();
    _press.dispose();
    super.dispose();
  }

  void _highlight(bool down) {
    _down = down;
    if (down) {
      _press.forward();
    } else if (!_press.isAnimating) {
      _press.reverse();
    }
  }

  void _tap() {
    if (widget.haptic) HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final padding = widget.padding;
    Widget content = padding == null
        ? widget.child
        : Padding(padding: padding, child: widget.child);
    final enabled = widget.onTap != null;
    if (enabled) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: _tap,
          onHighlightChanged: _highlight,
          borderRadius: widget.borderRadius,
          splashFactory: widget.ripple ? null : NoSplash.splashFactory,
          highlightColor: widget.ripple ? null : Colors.transparent,
          child: content,
        ),
      );
    }
    final decoration = widget.decoration;
    if (decoration != null) {
      content = AnimatedContainer(
        duration: AppMotion.fast,
        decoration: decoration,
        clipBehavior: widget.clipBehavior,
        child: content,
      );
    }
    if (!enabled) return content;
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: ScaleTransition(scale: _scale, child: content),
    );
  }
}
