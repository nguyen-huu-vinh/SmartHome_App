import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/assets.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../widgets/app_image.dart';
import 'auth/login_screen.dart';

/// Nội dung 1 trang giới thiệu: tiêu đề có 1 cụm tô màu brand + mô tả.
typedef _Intro = ({
  String image,
  String before,
  String highlight,
  String after,
  String desc,
});

final _pages = <_Intro>[
  (
    image: AppImages.onboarding[0],
    before: 'Control Your ',
    highlight: 'Uncontrolled',
    after: '\nDevices with Hoome',
    desc: 'All New AI Home smart devices control at your fingertips',
  ),
  (
    image: AppImages.onboarding[1],
    before: 'Seamless ',
    highlight: 'Integration',
    after: ' for\nEvery Smart Device',
    desc:
        'Connect and manage all your home gadgets in one powerful app — '
        'instantly and effortlessly',
  ),
  (
    image: AppImages.onboarding[2],
    before: 'Smart, Secure, and ',
    highlight: 'Always',
    after: '\nin Sync',
    desc:
        'Experience peace of mind with real-time control, monitoring, and '
        'automation — wherever you are.',
  ),
];

/// 3 trang giới thiệu, vuốt hoặc bấm Next; trang cuối → đăng nhập.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _index = 0;

  bool get _first => _index == 0;
  bool get _last => _index == _pages.length - 1;

  void _go(int page) {
    HapticFeedback.selectionClick();
    _ctrl.animateToPage(page, duration: AppMotion.slow, curve: AppMotion.curve);
  }

  void _start() {
    HapticFeedback.mediumImpact();
    Navigator.push(context, riseRoute(const LoginScreen()));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _button(String text, VoidCallback onTap, Color bg, Color fg) =>
      FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          minimumSize: const Size(110, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            side: const BorderSide(color: AppColors.line),
          ),
        ),
        child: AnimatedSwitcher(
          duration: AppMotion.fast,
          child: Text(text, key: ValueKey(text)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _ctrl,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _Page(_pages[i], i, _ctrl),
                ),
              ),
              const SizedBox(height: 24),
              Semantics(
                label: 'Page ${_index + 1} of ${_pages.length}',
                child: SizedBox(
                  width: 124,
                  height: 8,
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, _) {
                      final p = _ctrl.hasClients ? _ctrl.page ?? 0.0 : 0.0;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(height: 2, color: const Color(0xFFE2E2E8)),
                          Positioned(
                            left: p * 44,
                            child: Container(
                              width: 36,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A33),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  _button(
                    _first ? 'Skip Intro' : 'Back',
                    () => _go(_first ? _pages.length - 1 : _index - 1),
                    const Color(0xFFF4F5F7),
                    AppColors.dark,
                  ),
                  const Spacer(),
                  _button(
                    _last ? 'Let’s Go ✨' : 'Next',
                    _last ? _start : () => _go(_index + 1),
                    AppColors.dark,
                    Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Một trang: ảnh trượt chậm hơn (parallax), chữ mờ dần theo tay vuốt.
class _Page extends StatelessWidget {
  const _Page(this.data, this.index, this.ctrl);

  final _Intro data;
  final int index;
  final PageController ctrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final page = ctrl.hasClients && ctrl.position.haveDimensions
            ? ctrl.page!
            : 0.0;
        final d = (page - index).clamp(-1.0, 1.0); // -1..1, 0 = đang hiển thị
        final width = MediaQuery.sizeOf(context).width;
        return Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(200),
                  bottom: Radius.circular(24),
                ),
                child: Transform.translate(
                  offset: Offset(d * width * 0.3, 0),
                  child: Transform.scale(
                    scale: 1.15,
                    child: AppImage(
                      data.image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Opacity(
              opacity: 1 - d.abs(),
              child: Transform.translate(
                offset: Offset(d * 60, 0),
                child: Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        style: AppText.semibold(24).copyWith(height: 1.35),
                        children: [
                          TextSpan(text: data.before),
                          TextSpan(
                            text: data.highlight,
                            style: const TextStyle(color: AppColors.brand),
                          ),
                          TextSpan(text: data.after),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.desc,
                      textAlign: TextAlign.center,
                      style: AppText.subtitle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
