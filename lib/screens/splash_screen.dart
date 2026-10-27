import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/assets.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import 'onboarding_screen.dart';

/// Logo hiện dần trên các vòng tròn xanh nhạt, 2 giây sau sang Onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _duration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    Future.delayed(_duration, () {
      if (!mounted) return;
      Navigator.pushReplacement(context, smoothRoute(const OnboardingScreen()));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nạp sẵn ảnh Onboarding trong lúc chờ → sang trang là thấy ngay.
    for (final image in AppImages.onboarding) {
      precacheImage(AssetImage(image), context);
    }
  }

  Widget _circle(double size, Color color) =>
      CircleAvatar(radius: size / 2, backgroundColor: color);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: AppMotion.curve,
          builder: (_, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _circle(415, const Color(0xFFF3FAFF)),
              _circle(260, AppColors.sky),
              _circle(130, const Color(0xFFDCF0FF)),
              Semantics(
                header: true,
                label: 'Hoome',
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      const Icon(
                        Icons.home_outlined,
                        size: 40,
                        color: AppColors.brand,
                      ),
                      Text(
                        'Hoome',
                        style: GoogleFonts.nunito(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
