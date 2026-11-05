import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../l10n/l10n.dart';

/// 1 bước giới thiệu: làm sáng [target] và hiện thẻ giải thích cạnh đó.
class TourStep {
  const TourStep({
    required this.target,
    required this.icon,
    required this.title,
    required this.message,
    this.radius = AppSizes.radiusM,
  });

  /// Gắn vào widget cần giới thiệu (VD: `KeyedSubtree(key: target, ...)`).
  final GlobalKey target;
  final IconData icon;
  final String title;
  final String message;

  /// Độ bo góc của chỗ được làm sáng (để vùng sáng ôm đúng hình);
  /// nút tròn / viên thuốc → số lớn, tự thành hình tròn.
  final double radius;
}

/// Giới thiệu app lần đầu: phủ tối màn hình, chừa sáng từng chỗ, thẻ giải
/// thích có "Skip" / "Next". Xem xong hoặc bỏ qua → ghi nhớ vào máy.
abstract final class AppTour {
  static const _seenKey = 'tour_done';

  /// Đã xem (hoặc bỏ qua) hướng dẫn chưa.
  static Future<bool> seen() async =>
      (await SharedPreferences.getInstance()).getBool(_seenKey) ?? false;

  /// Chạy hướng dẫn. Chỗ nào chưa có trên màn (VD: danh sách rỗng) thì bỏ qua.
  static Future<void> show(BuildContext context, List<TourStep> steps) async {
    final shown = [
      for (final s in steps)
        if (s.target.currentContext != null) s,
    ];
    if (shown.isEmpty) return;
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        transitionDuration: AppMotion.medium,
        reverseTransitionDuration: AppMotion.fast,
        pageBuilder: (_, _, _) => _TourView(steps: shown),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
    await (await SharedPreferences.getInstance()).setBool(_seenKey, true);
  }
}

class _TourView extends StatefulWidget {
  const _TourView({required this.steps});

  final List<TourStep> steps;

  @override
  State<_TourView> createState() => _TourViewState();
}

class _TourViewState extends State<_TourView> {
  var _index = 0;

  /// Vùng đang làm sáng (toạ độ màn hình); null → chưa đo xong.
  Rect? _hole;

  @override
  void initState() {
    super.initState();
    _go(0);
  }

  /// Cuộn tới chỗ của bước [i] (nếu nằm trong danh sách cuộn) rồi đo vị trí.
  Future<void> _go(int i) async {
    final target = widget.steps[i].target.currentContext;
    if (target != null) {
      await Scrollable.ensureVisible(
        target,
        alignment: 0.5,
        duration: AppMotion.medium,
        curve: AppMotion.curve,
      );
    }
    if (!mounted) return;
    setState(() {
      _index = i;
      _hole = _measure(widget.steps[i].target, MediaQuery.sizeOf(context));
    });
  }

  /// Chừa quanh chỗ được làm sáng.
  static const _pad = 4.0;

  /// Vùng cần sáng (toạ độ màn hình), không tràn sát mép màn hình
  /// (VD: hàng phòng cuộn ngang tràn hết bề ngang).
  static Rect? _measure(GlobalKey key, Size screen) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final rect = (box.localToGlobal(Offset.zero) & box.size).inflate(_pad);
    return rect
        .intersect(Offset.zero & screen)
        .intersect(Rect.fromLTRB(8, 0, screen.width - 8, screen.height));
  }

  void _next() {
    if (_index + 1 < widget.steps.length) {
      _go(_index + 1);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final hole = _hole;
    // Thẻ đặt ở phía còn nhiều chỗ hơn (dưới hoặc trên vùng sáng).
    final below = hole == null || size.height - hole.bottom > hole.top;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder<Rect?>(
              tween: RectTween(
                end:
                    hole ??
                    Rect.fromCenter(
                      center: size.center(Offset.zero),
                      width: 0,
                      height: 0,
                    ),
              ),
              duration: AppMotion.medium,
              curve: AppMotion.curve,
              builder: (_, r, _) => CustomPaint(
                painter: _ScrimPainter(
                  r!,
                  widget.steps[_index].radius + _TourViewState._pad,
                ),
              ),
            ),
          ),
          if (hole != null)
            Positioned(
              left: AppSizes.gutter,
              right: AppSizes.gutter,
              top: below ? hole.bottom + 12 : null,
              bottom: below ? null : size.height - hole.top + 12,
              child: Align(
                alignment: below ? Alignment.topCenter : Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: AnimatedSwitcher(
                    duration: AppMotion.fast,
                    child: _TourCard(
                      key: ValueKey(_index),
                      step: widget.steps[_index],
                      index: _index,
                      count: widget.steps.length,
                      onNext: _next,
                      onSkip: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Lớp phủ tối, khoét sáng [hole] và viền trắng quanh đó.
class _ScrimPainter extends CustomPainter {
  _ScrimPainter(this.hole, this.radius);

  final Rect hole;

  /// Độ bo góc của vùng sáng; lớn hơn nửa cạnh ngắn thì thành hình tròn / viên thuốc.
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      hole,
      Radius.circular(math.min(radius, hole.shortestSide / 2)),
    );
    canvas
      ..drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(Offset.zero & size)
          ..addRRect(r),
        Paint()..color = const Color(0x99000000),
      )
      ..drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white,
      );
  }

  @override
  bool shouldRepaint(_ScrimPainter old) =>
      old.hole != hole || old.radius != radius;
}

/// Thẻ giải thích: icon, tiêu đề, "2/6", nội dung, chấm chỉ bước, nút.
class _TourCard extends StatelessWidget {
  const _TourCard({
    super.key,
    required this.step,
    required this.index,
    required this.count,
    required this.onNext,
    required this.onSkip,
  });

  final TourStep step;
  final int index;
  final int count;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final last = index == count - 1;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: AppShadows.floating,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brand,
                ),
                child: Icon(step.icon, color: Colors.white),
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(step.title, style: AppText.semibold(20)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sky,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${index + 1}/$count',
                  semanticsLabel: context.l10n.tourStep(index + 1, count),
                  style: AppText.semibold(13, color: AppColors.skyLine),
                ),
              ),
            ],
          ),
          Text(step.message, style: AppText.body(size: 15)),
          Row(
            children: [
              _Dots(count: count, index: index),
              const Spacer(),
              if (!last)
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(foregroundColor: AppColors.grey),
                  child: Text(context.l10n.skip),
                ),
              const SizedBox(width: 4),
              FilledButton.icon(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.dark,
                  shape: const StadiumBorder(),
                ),
                iconAlignment: IconAlignment.end,
                icon: Icon(
                  last ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  size: 18,
                ),
                label: Text(last ? context.l10n.gotIt : context.l10n.next),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chấm chỉ bước: bước hiện tại là vạch dài.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        spacing: 4,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: AppMotion.fast,
              width: i == index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i <= index ? AppColors.dark : AppColors.muted,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
        ],
      ),
    );
  }
}
