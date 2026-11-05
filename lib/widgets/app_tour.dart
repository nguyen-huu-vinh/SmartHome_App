import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../l10n/l10n.dart';

/// 1 bước giới thiệu: khoanh [target] và hiện bong bóng giải thích cạnh đó.
class TourStep {
  const TourStep({
    required this.target,
    required this.icon,
    required this.title,
    required this.message,
    this.radius = AppSizes.radiusM,
    this.padding = const EdgeInsets.all(4),
    this.also = const [],
  });

  /// Gắn vào widget cần giới thiệu (VD: `KeyedSubtree(key: target, ...)`).
  final GlobalKey target;
  final IconData icon;
  final String title;
  final String message;

  /// Độ bo góc của chỗ được khoanh (để viền ôm đúng hình);
  /// nút tròn / viên thuốc → số lớn, tự thành hình tròn.
  final double radius;

  /// Lề từ chỗ được khoanh ra mép viền. Chỗ có phần trống bên trong
  /// (VD: mũi tên có lề riêng) → bù lại để vùng sáng ôm đều.
  final EdgeInsets padding;

  /// Các chỗ khác cùng được làm sáng chung với [target] (viền ôm cả
  /// nhóm), VD: dòng chữ nhỏ phía trên tên nhà.
  final List<GlobalKey> also;
}

/// Giới thiệu app lần đầu: nền mờ nhẹ, viền xanh khoanh từng chỗ, bong bóng
/// giải thích có mũi tên chỉ vào đó, nút "Skip" / "Next". Xem xong hoặc bỏ
/// qua → ghi nhớ vào máy.
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

class _TourViewState extends State<_TourView>
    with SingleTickerProviderStateMixin {
  var _index = 0;

  /// Vùng đang khoanh (toạ độ màn hình); null → chưa đo xong.
  Rect? _hole;

  /// Viền nhấp nháy vài lần mỗi khi sang bước mới, rồi đứng yên.
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _go(0);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
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
      _hole = _measure(widget.steps[i], MediaQuery.sizeOf(context));
    });
    _pulse.repeat(reverse: true, count: 4);
  }

  /// Lề mặc định quanh chỗ được khoanh (cũng dùng để bo góc đồng tâm).
  static const _pad = 4.0;

  /// Vùng cần khoanh (toạ độ màn hình), không tràn sát mép màn hình
  /// (VD: hàng phòng cuộn ngang tràn hết bề ngang).
  static Rect? _measure(TourStep step, Size screen) {
    Rect? bounds;
    for (final key in [step.target, ...step.also]) {
      final box = key.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      final r = box.localToGlobal(Offset.zero) & box.size;
      bounds = bounds?.expandToInclude(r) ?? r;
    }
    if (bounds == null) return null;
    final rect = step.padding.inflateRect(bounds);
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

  /// Khoảng cách từ viền tới bong bóng (chừa chỗ cho mũi tên).
  static const _gap = 14.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final hole = _hole;
    // Bong bóng đặt ở phía còn nhiều chỗ hơn (dưới hoặc trên chỗ được khoanh).
    final below = hole == null || size.height - hole.bottom > hole.top;
    final width = math.min(size.width - 2 * AppSizes.gutter, 360.0);
    final left = (size.width - width) / 2;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Chạm ra ngoài bong bóng không làm gì (tránh bấm nhầm vào app).
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
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
                  painter: _SpotPainter(
                    hole: hole == null ? null : r,
                    radius: widget.steps[_index].radius + _pad,
                    pulse: _pulse,
                  ),
                ),
              ),
            ),
          ),
          if (hole != null)
            Positioned(
              left: left,
              width: width,
              top: below ? hole.bottom + _gap : null,
              bottom: below ? null : size.height - hole.top + _gap,
              child: AnimatedSwitcher(
                duration: AppMotion.fast,
                child: _TourBubble(
                  key: ValueKey(_index),
                  step: widget.steps[_index],
                  index: _index,
                  count: widget.steps.length,
                  below: below,
                  // Mũi tên chỉ đúng giữa chỗ được khoanh, không ra sát mép.
                  arrowX: (hole.center.dx - left).clamp(28.0, width - 28),
                  onNext: _next,
                  onSkip: () => Navigator.pop(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Nền mờ nhẹ + viền xanh brand khoanh [hole] (có quầng nhấp nháy theo
/// [pulse]). [hole] null → chỉ có nền.
class _SpotPainter extends CustomPainter {
  _SpotPainter({required this.hole, required this.radius, required this.pulse})
    : super(repaint: pulse);

  final Rect? hole;

  /// Độ bo góc của viền; lớn hơn nửa cạnh ngắn thì thành hình tròn / viên thuốc.
  final double radius;
  final Animation<double> pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = this.hole;
    final scrim = Paint()..color = const Color(0x40000000);
    if (hole == null) return canvas.drawRect(Offset.zero & size, scrim);
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
        scrim,
      )
      // Quầng loang ra ngoài rồi mờ dần.
      ..drawRRect(
        r.inflate(pulse.value * 6),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = AppColors.brand.withValues(alpha: 0.55 * (1 - pulse.value)),
      )
      ..drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = AppColors.brand,
      );
  }

  @override
  bool shouldRepaint(_SpotPainter old) =>
      old.hole != hole || old.radius != radius;
}

/// Bong bóng giải thích: icon, tiêu đề, "2/4", nội dung, chấm chỉ bước, nút.
/// Có mũi tên ở cạnh trên ([below]) hoặc cạnh dưới, nằm tại [arrowX].
class _TourBubble extends StatelessWidget {
  const _TourBubble({
    super.key,
    required this.step,
    required this.index,
    required this.count,
    required this.below,
    required this.arrowX,
    required this.onNext,
    required this.onSkip,
  });

  final TourStep step;
  final int index;
  final int count;
  final bool below;
  final double arrowX;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  static const _arrow = 16.0;

  @override
  Widget build(BuildContext context) {
    final last = index == count - 1;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            boxShadow: AppShadows.floating,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                spacing: 10,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.sky,
                    ),
                    child: Icon(step.icon, size: 18, color: AppColors.skyLine),
                  ),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(step.title, style: AppText.semibold(16)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '${index + 1}/$count',
                      semanticsLabel: context.l10n.tourStep(index + 1, count),
                      style: AppText.body(size: 13, color: AppColors.grey),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  step.message,
                  style: AppText.body(size: 14).copyWith(height: 1.4),
                ),
              ),
              Row(
                children: [
                  _Dots(count: count, index: index),
                  const Spacer(),
                  if (!last)
                    TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.grey,
                        minimumSize: const Size(0, 36),
                      ),
                      child: Text(context.l10n.skip),
                    ),
                  FilledButton(
                    onPressed: onNext,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.dark,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(last ? context.l10n.gotIt : context.l10n.next),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Mũi tên: hình thoi trắng, nửa dưới chìm vào bong bóng.
        Positioned(
          left: arrowX - _arrow / 2,
          top: below ? -_arrow / 2 + 1 : null,
          bottom: below ? null : -_arrow / 2 + 1,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: _arrow,
              height: _arrow,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
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
