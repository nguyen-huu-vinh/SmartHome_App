import 'package:flutter/material.dart';

import '../core/assets.dart';
import '../core/theme.dart';
import 'app_image.dart';
import 'pressable.dart';

/// Khung chung cho các màn đăng nhập/đăng ký:
/// ảnh nền phía trên + khối trắng bo góc chứa [children].
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.children,
    this.fitContent = false,
    this.heroMaxFraction = 0.4,
  });

  final List<Widget> children;

  /// true: khối trắng cao vừa đủ nội dung (neo đáy màn hình).
  /// false: khối trắng bắt đầu ngay dưới ảnh và kéo tới đáy.
  final bool fitContent;

  /// Ảnh cao tối đa bao nhiêu phần màn hình.
  final double heroMaxFraction;

  /// Khi [fitContent], luôn chừa ít nhất chừng này px cho ảnh.
  static const _minHeroVisible = 160.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Cao theo đúng tỉ lệ ảnh gốc, không kéo giãn hết màn hình.
    final heroH = (size.width * AppImages.authHeroRatio).clamp(
      0.0,
      size.height * heroMaxFraction,
    );
    final card = DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusSheet),
        ),
      ),
      child: AutofillGroup(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16,
            fitContent ? 20 : 24,
            16,
            16 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ảnh phải nằm trong Positioned có chiều cao, nếu không sẽ bị
          // kéo giãn theo cả màn hình và chỉ lộ ra phần tường trắng.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroH + AppSizes.radiusSheet,
            child: const AppImage(
              AppImages.authHero,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          if (fitContent)
            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: size.height - _minHeroVisible,
                ),
                child: card,
              ),
            )
          else
            Positioned.fill(top: heroH, child: card),
        ],
      ),
    );
  }
}

/// Tiêu đề lớn + dòng mô tả xám.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle = 'Welcome to Hoome’s world of digital technology.',
    this.subtitleExtra = const [],
    this.titleExtra = const [],
  });

  final String title;

  /// Phần nối thêm sau [title] (vd: tên loại thiết bị tô màu brand).
  final List<InlineSpan> titleExtra;
  final String subtitle;

  /// Phần nối thêm sau [subtitle] (vd: email được tô đậm).
  final List<InlineSpan> subtitleExtra;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(text: title, children: titleExtra),
          style: AppText.title,
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            text: subtitle,
            style: AppText.subtitle,
            children: subtitleExtra,
          ),
        ),
      ],
    );
  }
}

/// Dòng cuối căn giữa: "Don’t have an account? Create Account".
class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.text,
    required this.link,
    required this.onTap,
    this.fontSize = 14,
  });

  final String text, link;
  final VoidCallback onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(text, style: AppText.body(size: fontSize)),
          Pressable(
            onTap: onTap,
            ripple: false,
            scale: 0.95,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(link, style: AppText.link(size: fontSize)),
          ),
        ],
      ),
    );
  }
}
